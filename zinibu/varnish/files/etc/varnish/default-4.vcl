# Managed by saltstack.
# host id: {{ salt['grains.get']('id', '') }}
{% set settings = salt['pillar.get']('varnish', {}) -%}
{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}
#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and https://www.varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

import std;
import directors;

{%- for id, haproxy_server in zinibu_basic.project.haproxy_servers.iteritems() %}
backend bk_appsrv_static_{{ id }} {
  .host = "{{ haproxy_server.private_ip }}";
  .port = "{{ haproxy_server.port }}";
  .probe = {
    .url = "{{ zinibu_basic.project.haproxy_check }}";
    .expected_response = 200;
    .timeout = 1s;
    .interval = 3s;
    .window = 2;
    .threshold = 2;
    .initial = 2;
  }
}
{%- endfor %}

sub vcl_init {
    new bar = directors.round_robin();
{%- for id, haproxy_server in zinibu_basic.project.haproxy_servers.iteritems() %}
    bar.add_backend(bk_appsrv_static_{{ id }});
{%- endfor %}
}

acl purge {
    "localhost";
    "127.0.0.1";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    # debug bypass
    #return (pass);

    #std.log("vcl recv: "+req.request);

    # send all traffic to the bar director:
    set req.backend_hint = bar.backend();

    # Normalize the header, remove the port (in case you're testing this on various TCP ports)
    set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

    # Normalize the query arguments
    set req.url = std.querysort(req.url);

    # Allow purging
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) { # purge is the ACL defined at the begining
	    # Not from an allowed IP? Then die with an error.
            return (synth(405, "This IP is not allowed to send PURGE requests."));
        }
        # If you got this stage (and didn't error out above), purge the cached result
        return (purge);
    }

    # Only deal with "normal" types
    if (req.method != "GET" &&
        req.method != "HEAD" &&
        req.method != "PUT" &&
        req.method != "POST" &&
        req.method != "TRACE" &&
        req.method != "OPTIONS" &&
        req.method != "PATCH" &&
        req.method != "DELETE") {
      /* Non-RFC2616 or CONNECT which is weird. */
      return (pipe);
    }

    # Implementing websocket support (https://www.varnish-cache.org/docs/4.0/users-guide/vcl-example-websockets.html)
    if (req.http.Upgrade ~ "(?i)websocket") {
      return (pipe);
    }

    # Only cache GET or HEAD requests. This makes sure the POST requests are always passed.
    if (req.method != "GET" && req.method != "HEAD") {
      return (pass);
    }

    # Django is setting this cookie so we only check here
    if (req.http.Cookie ~ "LOGGED_IN") {
      return (pass);
    }

    if (req.http.Authorization) {
      # Not cacheable by default
      return (pass);
    }

    # unless sessionid/csrftoken is in the request, don't pass ANY cookies (referral_source, utm, etc)
    if (req.method == "GET" && (req.url ~ "^/media" || req.url ~ "^/static" || (req.http.Cookie !~ "sessionid" && req.http.Cookie !~ "csrftoken"))) {
      unset req.http.Cookie;
      return (hash);
    }

    # Large static files are delivered directly to the end-user without
    # waiting for Varnish to fully read the file first.
    # Varnish 4 fully supports Streaming, so set do_stream in vcl_backend_response()
    if (req.url ~ "^[^?]*\.(7z|avi|bz2|flac|flv|gz|mka|mkv|mov|mp3|mp4|mpeg|mpg|ogg|ogm|opus|rar|tar|tgz|tbz|txz|wav|webm|xz|zip)(\?.*)?$") {
      unset req.http.Cookie;
      return (hash);
    }

    # Remove all cookies for static files
    # A valid discussion could be held on this line: do you really need to cache static files that don't cause load? Only if you have memory left.
    # Sure, there's disk I/O, but chances are your OS will already have these files in their buffers (thus memory).
    # Before you blindly enable this, have a read here: https://ma.ttias.be/stop-caching-static-files/
    if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|otf|ogg|ogm|opus|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
      unset req.http.Cookie;
      return (hash);
    }
    
    # Are there cookies left with only spaces or that are empty?
    if (req.http.cookie ~ "^\s*$") {
      unset req.http.Cookie;
    }

    # Some generic cookie manipulation, useful for all templates that follow
    # Remove the "has_js" cookie
    set req.http.Cookie = regsuball(req.http.Cookie, "has_js=[^;]+(; )?", "");

    # Remove any Google Analytics based cookies
    set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "_ga=[^;]+(; )?", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "_gat=[^;]+(; )?", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "utmctr=[^;]+(; )?", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "utmcmd.=[^;]+(; )?", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "utmccn.=[^;]+(; )?", "");

    # Remove DoubleClick offensive cookies
    set req.http.Cookie = regsuball(req.http.Cookie, "__gads=[^;]+(; )?", "");

    # Remove the Quant Capital cookies (added by some plugin, all __qca)
    #set req.http.Cookie = regsuball(req.http.Cookie, "__qc.=[^;]+(; )?", "");

    # Remove the AddThis cookies
    #set req.http.Cookie = regsuball(req.http.Cookie, "__atuv.=[^;]+(; )?", "");

    # Remove a ";" prefix in the cookie if present
    set req.http.Cookie = regsuball(req.http.Cookie, "^;\s*", "");

    if (req.http.Cache-Control ~ "(?i)no-cache") {
    #if (req.http.Cache-Control ~ "(?i)no-cache" && client.ip ~ editors) { # create the acl editors if you want to restrict the Ctrl-F5
      # http://varnish.projects.linpro.no/wiki/VCLExampleEnableForceRefresh
      # Ignore requests via proxy caches and badly behaved crawlers
      # like msnbot that send no-cache with every request.
      if (! (req.http.Via || req.http.User-Agent ~ "(?i)bot" || req.http.X-Purge)) {
        #set req.hash_always_miss = true; # Doesn't seems to refresh the object in the cache
        return(purge); # Couple this with restart in vcl_purge and X-Purge header to avoid loops
      }
    }

    # Strip hash, server doesn't need it.
    if (req.url ~ "\#") {
      set req.url = regsub(req.url, "\#.*$", "");
    }

    # Strip a trailing ? if it exists
    if (req.url ~ "\?$") {
      set req.url = regsub(req.url, "\?$", "");
    }

    return (hash);
}

sub vcl_pipe {
  # Called upon entering pipe mode.
  # In this mode, the request is passed on to the backend, and any further data from both the client
  # and backend is passed on unaltered until either end closes the connection. Basically, Varnish will
  # degrade into a simple TCP proxy, shuffling bytes back and forth. For a connection in pipe mode,
  # no other VCL subroutine will ever get called after vcl_pipe.

  # Note that only the first request to the backend will have
  # X-Forwarded-For set.  If you use X-Forwarded-For and want to
  # have it set for all requests, make sure to have:
  # set bereq.http.connection = "close";
  # here.  It is not set by default as it might break some broken web
  # applications, like IIS with NTLM authentication.

  # set bereq.http.Connection = "Close";

  # Implementing websocket support (https://www.varnish-cache.org/docs/4.0/users-guide/vcl-example-websockets.html)
  if (req.http.upgrade) {
    set bereq.http.upgrade = req.http.upgrade;
  }

  return (pipe);
}

sub vcl_pass {
  # Called upon entering pass mode. In this mode, the request is passed on to the backend, and the
  # backend's response is passed on to the client, but is not entered into the cache. Subsequent
  # requests submitted over the same client connection are handled normally.

  # return (pass);
}

sub vcl_hash {
    # Called after vcl_recv to create a hash value for the request. This is used as a key
    # to look up the object in Varnish.
  
    hash_data(req.url);
  
    if (req.http.host) {
      hash_data(req.http.host);
    } else {
      hash_data(server.ip);
    }
  
    # hash cookies for requests that have them
    if (req.http.Cookie) {
      hash_data(req.http.Cookie);
    }

    return (lookup);
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.

    # Called after the response headers has been successfully retrieved from the backend.

    # Pause ESI request and remove Surrogate-Control header
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
      unset beresp.http.Surrogate-Control;
      set beresp.do_esi = true;
    }

    # Enable cache for all static files
    # The same argument as the static caches from above: monitor your cache size, if you get data nuked out of it, consider giving up the static file cache.
    # Before you blindly enable this, have a read here: https://ma.ttias.be/stop-caching-static-files/
    if (bereq.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|otf|ogg|ogm|opus|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
      unset beresp.http.set-cookie;
    }

    # Large static files are delivered directly to the end-user without
    # waiting for Varnish to fully read the file first.
    # Varnish 4 fully supports Streaming, so use streaming here to avoid locking.
    if (bereq.url ~ "^[^?]*\.(7z|avi|bz2|flac|flv|gz|mka|mkv|mov|mp3|mp4|mpeg|mpg|ogg|ogm|opus|rar|tar|tgz|tbz|txz|wav|webm|xz|zip)(\?.*)?$") {
      unset beresp.http.set-cookie;
      set beresp.do_stream = true;  # Check memory usage it'll grow in fetch_chunksize blocks (128k by default) if the backend doesn't send a Content-Length header, so only enable it for big objects
      set beresp.do_gzip   = false;   # Don't try to compress it for storage
    }

    # Sometimes, a 301 or 302 redirect formed via Apache's mod_rewrite can mess with the HTTP port that is being passed along.
    # This often happens with simple rewrite rules in a scenario where Varnish runs on :80 and Apache on :8080 on the same box.
    # A redirect can then often redirect the end-user to a URL on :8080, where it should be :80.
    # This may need finetuning on your setup.
    #
    # To prevent accidental replace, we only filter the 301/302 redirects for now.
    if (beresp.status == 301 || beresp.status == 302) {
      set beresp.http.Location = regsub(beresp.http.Location, ":[0-9]+", "");
    }

    # Set 2min cache if unset for static files
    if (beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary == "*") {
      set beresp.ttl = 120s; # Important, you shouldn't rely on this, SET YOUR HEADERS in the backend
      set beresp.uncacheable = true;

      # Study and test this
      # Mark as "Hit-For-Pass" for the next 60 minutes - 24 hours
      #if (bereq.url ~ "\.(jpe?g|png|gif|pdf|gz|tgz|bz2|tbz|tar|zip|tiff|tif)$" || bereq.url ~ "/(image|(image_(?:[^/]|(?!view.*).+)))$") {
      #    set beresp.ttl = std.duration(beresp.http.age+"s",0s) + 6h;
      #} elseif (bereq.url ~ "\.(svg|swf|ico|mp3|mp4|m4a|ogg|mov|avi|wmv|flv)$") {
      #    set beresp.ttl = std.duration(beresp.http.age+"s",0s) + 6h;
      #} elseif (bereq.url ~ "\.(xls|vsd|doc|ppt|pps|vsd|doc|ppt|pps|xls|pdf|sxw|rar|odc|odb|odf|odg|odi|odp|ods|odt|sxc|sxd|sxi|sxw|dmg|torrent|deb|msi|iso|rpm)$") {
      #    set beresp.ttl = std.duration(beresp.http.age+"s",0s) + 6h;
      #} elseif (bereq.url ~ "\.(css|js)$") {
      #    set beresp.ttl = std.duration(beresp.http.age+"s",0s) + 24h;
      #} else {
      #    set beresp.ttl = std.duration(beresp.http.age+"s",0s) + 1h;
      #}

      return (deliver);
    }

    # Don't cache 50x responses
    if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
      return (abandon);
    }

    # Allow stale content, in case the backend goes down.
    # make Varnish keep all objects for 6 hours beyond their TTL
    set beresp.grace = 6h;

    return (deliver);
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

    # Called before a cached object is delivered to the client.

    if (obj.hits > 0) { # Add debug header to see if it's a HIT/MISS and the number of hits, disable when not needed
      set resp.http.X-Cache = "HIT";
    } else {
      set resp.http.X-Cache = "MISS";
    }

    # Please note that obj.hits behaviour changed in 4.0, now it counts per objecthead, not per object
    # and obj.hits may not be reset in some cases where bans are in use. See bug 1492 for details.
    # So take hits with a grain of salt
    set resp.http.X-Cache-Hits = obj.hits;

    # Remove some headers: PHP version
    unset resp.http.X-Powered-By;

    # Remove some headers: Apache version & OS
    unset resp.http.Server;
    unset resp.http.X-Drupal-Cache;
    unset resp.http.X-Varnish;
    unset resp.http.Via;
    unset resp.http.Link;
    unset resp.http.X-Generator;

    return (deliver);
}

sub vcl_purge {
  # Only handle actual PURGE HTTP methods, everything else is discarded
  if (req.method != "PURGE") {
    # restart request
    set req.http.X-Purge = "Yes";
    return(restart);
  }
}

sub vcl_synth {
    set resp.http.Content-Type = "text/html; charset=utf-8";
    set resp.http.Retry-After = "5";
    synthetic ("Error");
    return (deliver);
}
