# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
# TODO ESI logic for Django. See default-4.vcl
# 
# Default backend definition.  Set this to point to your content
# server.
# 

# Managed by saltstack.
# host id: {{ salt['grains.get']('id', '') }}
{% set settings = salt['pillar.get']('varnish', {}) -%}
{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

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

director bk_appsrv_static_director fallback {
{%- for id, haproxy_server in zinibu_basic.project.haproxy_servers.iteritems() %}
  { .backend = bk_appsrv_static_{{ id }}; }
{%- endfor %}
}

acl purge {
    "localhost";
}

sub vcl_recv {
    # Health Checking
    if (req.url == "{{ zinibu_basic.project.varnish_check }}") {
        error 751 "health check OK!";
    }

    # debug bypass
    #return (pass);
    #

    # Set default backend
    set req.backend = bk_appsrv_static_director;

    # conditions examples
    # if (req.url ~ "^/yte-admin" || req.url ~ "^/accounts/" || req.url ~ "^/api/v1" || req.url ~ "^/sweeps" || req.url ~ "^/questions" || req.url ~ "^/static" || req.url ~ "^/media/"  || req.url ~ "^/dj-admin") {
    #   set req.backend = django_balancer;
    # } else {
    #   set req.backend = drupal_balancer;
    # }

    # TODO normalize namespace, use correct domain
    # https://www.varnish-cache.org/docs/3.0/tutorial/increasing_your_hitrate.html#normalizing-your-namespace
    #if (req.http.host ~ "(?i)^(www.)?varnish-?software.com") {
    #    set req.http.host = "varnish-software.com";
    #}
    
    # https://www.varnish-cache.org/docs/3.0/reference/vcl.html#varnish-configuration-language
    # You can use the set keyword to set arbitrary HTTP headers. You can remove headers with the remove or unset keywords, which are synonyms.
    #
    # If multiple subroutines with the the name of one of the builtin ones are defined, they are concatenated in the order in which they appear in the source. The default versions distributed with Varnish will be implicitly concatenated as a last resort at the end.

    # drop cookies (and respond from cache) if backends are down, do we still need it if we have probe?
    #if (!req.backend.healthy) {
    #  unset req.http.Cookie;
    #}

    # examples of avoiding caching
    #if (req.url ~ "^/status\.php$" ||
    #    req.url ~ "^/update\.php$" ||
    #    req.url ~ "^/ooyala/ping$" ||
    #    req.url ~ "^/admin/build/features" ||
    #    req.url ~ "^/info/.*$" ||
    #    req.url ~ "^/flag/.*$" ||
    #    req.url ~ "^.*/ajax/.*$" ||
    #    req.url ~ "^/dj-admin/" ||
    #    req.url ~ "^/questions/from-external-login/" ||
    #    req.url ~ "^/experts/search/" ||
    #    req.url ~ "^.*/ahah/.*$") {
    #     return (pass);
    #}
    
    # Pipe these paths directly for streaming.
    # Further investigation needed. Maybe for big downloads.
    #if (req.url ~ "^/admin/content/backup_migrate/export") {
    #  return (pipe);
    #}
 
    # Purge request
    if (req.request == "PURGE") {
        if (!client.ip ~ purge) {
            error 405 "Not allowed.";
        }
        return (lookup);
    }

    # unless sessionid/csrftoken is in the request, don't pass ANY cookies (referral_source, utm, etc)
    if (req.request == "GET" && (req.url ~ "^/media" || req.url ~ "^/static" || (req.http.cookie !~ "sessionid" && req.http.cookie !~ "csrftoken"))) {
        remove req.http.Cookie;
    }

    # Always cache the following file types for all users.
    if (req.url ~ "(?i)\.(png|gif|jpeg|jpg|ico|swf|css|js|htm|html)(\?[a-z0-9]+)?$") {
      unset req.http.Cookie;
    }
    
    # static and media files always cached 
    if (req.url ~ "^/static" || req.url ~ "^/media") {
      unset req.http.Cookie;
    }

    # redundant?
    # Static objects are first looked up in the cache
    #if (req.url ~ ".(png|gif|jpg|swf|css|js)(?.*|)$") {
    #    return (lookup);
    #}

    #######################################
    ## Strip hash, server doesn't need it.
    #if (req.url ~ "\#") {
    #  set req.url=regsub(req.url,"\#.*$","");
    #}
    #
    ## Strip out Google related parameters
    #if (req.url ~ "(\?|&)(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=") {
    #  set req.url=regsuball(req.url,"&(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)","");
    #  set req.url=regsuball(req.url,"\?(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)","?");
    #  set req.url=regsub(req.url,"\?&","?");
    #  set req.url=regsub(req.url,"\?$","");
    #}
    #
    ## Django is setting this cookie so we only check here
    #if (req.http.Cookie ~ "LOGGED_IN") {
    #  return (pass);
    #}
    #
    ## new lullabot cookies logic
    ## Remove all cookies that Drupal doesn't need to know about. ANY remaining
    ## cookie will cause the request to pass-through to Apache. For the most part
    ## we always set the NO_CACHE cookie after any POST request, disabling the
    ## Varnish cache temporarily. The session cookie allows all authenticated users
    ## to pass through as long as they're logged in.
    #
    #if (req.http.Cookie) {
    #  set req.http.Cookie = ";" + req.http.Cookie;
    #  set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
    #  # replace this original line to include Django's LOGGED_IN
    #  #set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|NO_CACHE)=", "; \1=");
    #  set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|NO_CACHE|LOGGED_IN)=", "; \1=");
    #  set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
    #  set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");
    #
    #  if (req.http.Cookie == "") {
    #    # If there are no remaining cookies, remove the cookie header. If there
    #    # aren't any cookie headers, Varnish's default behavior will be to cache
    #    # the page.
    #    unset req.http.Cookie;
    #  }
    #  else {
    #    # If there is any cookies left (a session or NO_CACHE cookie), do not
    #    # cache the page. Pass it on to Apache directly.
    #    return (pass);
    #  }
    #}
    #######################################

    # normalize accept-encoding to account for different browsers
    # see: https://www.varnish-cache.org/trac/wiki/VCLExampleNormalizeAcceptEncoding
    # Accept-Encoding header clean-up
    if (req.http.Accept-Encoding) {
        # use gzip when possible, otherwise use deflate
        if (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            # unknown algorithm, remove accept-encoding header
            unset req.http.Accept-Encoding;
        }
        
        # Microsoft Internet Explorer 6 is well know to be buggy with compression and css / js
        if (req.url ~ ".(css|js)" && req.http.User-Agent ~ "MSIE 6") {
            remove req.http.Accept-Encoding;
        }
    }

    # Per host/application configuration
    # bk_appsrv_static
    # Stale content delivery
    if (req.backend.healthy) {
        set req.grace = 30s;
    } else {
        set req.grace = 1d;
    }
    
    # unneeded?
    # Cookie ignored in these static pages
    #unset req.http.cookie;
}

# Routine used to determine the cache key if storing/retrieving a cached page.
sub vcl_hash {
    hash_data(req.url);
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (hash);
}

sub vcl_hit {
    # Purge
    if (req.request == "PURGE") {
        set obj.ttl = 0s;
        error 200 "Purged.";
    }
    return (deliver);
}

sub vcl_miss {
    # Purge
    if (req.request == "PURGE") {
        error 404 "Not in cache.";
    }
    return (fetch);
}

sub vcl_fetch {
    # Stale content delivery
    set beresp.grace = 1d;
    
    # static files always cached 
    if (req.url ~ "^/media" || req.url ~ "^/static") {
       unset beresp.http.set-cookie;
       return (deliver);  
    }

    # TODO should I pass some of this caching of app servers to haproxy?
    # pass through for anything with a session/csrftoken set
    if (beresp.http.set-cookie ~ "sessionid" || beresp.http.set-cookie ~ "csrftoken") {
        # hit_for_pass: Pass in fetch. This will create a hit_for_pass object. Note that the TTL for the hit_for_pass object will be set to what the current value of beresp.ttl. Control will be handled to vcl_deliver on the current request, but subsequent requests will go directly to vcl_pass based on the hit_for_pass object.

        # this is to control time to cache this url
        #set beresp.ttl = 10s;
        return (hit_for_pass);
    } else {
        return (deliver);
    }

    # Some optional logic from Drupal
    # if (req.url ~ "^/api/v1") {
    #   set beresp.ttl = 10s;
    #   return (deliver);
    # }
    # 
    # if (req.url == "/questions/esi-test/") {
    #    set beresp.ttl = 1s;
    #    #set beresp.ttl = 5m;
    # } else {
    #    set beresp.do_esi = true; /* Do ESI processing               */
    #    set beresp.ttl = 24h;
    # }
    # 
    # # Don't allow static files to set cookies.
    # if (req.url ~ "(?i)\.(png|gif|jpeg|jpg|ico|swf|css|js|html|htm)(\?[a-z0-9]+)?$") {
    #   # beresp == Back-end response from the web server.
    #   unset beresp.http.set-cookie;
    # }
    # 
    # # static and media files always cached 
    # if (req.url ~ "^/static" || req.url ~ "^/media") {
    #    unset beresp.http.set-cookie;
    # }
    # 
    # if (req.url ~ "^/accounts/login" || req.url ~ "^/accounts/register" || req.url ~ "^/accounts/password" || req.url ~ "^/questions/$" || req.url ~ "^/questions/login/" || req.url ~ "^/questions/from-external-login/") {
    #    return (hit_for_pass);
    # }
    # 
    # # notice Drupal URLs don't have the trailing slash
    # # /experts/user-register and /experts/payment-options are needed to fix YTE join problem in Firefox and other Windows browsers
    # #if (req.url !~ "^/dj-admin/$" && req.url !~ "^/questions/$" && req.url !~ "^/questions/login/" && req.url !~ "^/questions/from-external-login/" && req.http.Cookie !~ "sessionid" && req.http.Cookie !~ "csrftoken" && req.url !~ "^/user/login" && req.url !~ "^/experts/user-register" && req.http.Cookie !~ "LOGGED_IN" && req.http.Cookie !~ "SESS[a-z0-9]+") {
    # if (req.url !~ "^/api/user" && req.url !~ "^/accounts/login" && req.url !~ "^/accounts/register" && req.url !~ "^/accounts/password" && req.url !~ "^/dj-admin/$" && req.url !~ "^/questions/$" && req.url !~ "^/questions/login/" && req.url !~ "^/questions/from-external-login/" && req.http.Cookie !~ "sessionid" && req.http.Cookie !~ "csrftoken" && req.url !~ "^/user/login" && req.url !~ "^/experts/user-register" && req.http.Cookie !~ "LOGGED_IN") {
    #    unset beresp.http.set-cookie;
    #    return (deliver);
    # } else {
    #    return (hit_for_pass);
    # }

#    TODO review
#    # Hide Server information
#    unset beresp.http.Server;
#    
#    # Store compressed objects in memory
#    # They would be uncompressed on the fly by Varnish if the client doesn't support compression
#    if (beresp.http.content-type ~ "(text|application)") {
#        set beresp.do_gzip = true;
#    }
#
#    # remove any cookie on static or pseudo-static objects
#    unset beresp.http.set-cookie;
}

sub vcl_deliver {
    # debugging
    #set resp.http.X-DEBUG-Varnish = "Hey, this is Varnish 3 on staging";
    #set resp.http.X-DEBUG-URL = "URL " + req.url;
    
    # optionally hide a couple of headers
    #unset resp.http.via;
    #unset resp.http.x-varnish;
    
    # could be useful to know if the object was in cache or not
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
}

sub vcl_error {
    # Health check
    if (obj.status == 751) {
        set obj.status = 200;
        return (deliver);
    }
}

# end of managed by saltstack.

#backend default {
#    .host = "127.0.0.1";
#    .port = "8080";
#}
# 
# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.
# sub vcl_recv {
#     if (req.restarts == 0) {
# 	if (req.http.x-forwarded-for) {
# 	    set req.http.X-Forwarded-For =
# 		req.http.X-Forwarded-For + ", " + client.ip;
# 	} else {
# 	    set req.http.X-Forwarded-For = client.ip;
# 	}
#     }
#     if (req.request != "GET" &&
#       req.request != "HEAD" &&
#       req.request != "PUT" &&
#       req.request != "POST" &&
#       req.request != "TRACE" &&
#       req.request != "OPTIONS" &&
#       req.request != "DELETE") {
#         /* Non-RFC2616 or CONNECT which is weird. */
#         return (pipe);
#     }
#     if (req.request != "GET" && req.request != "HEAD") {
#         /* We only deal with GET and HEAD by default */
#         return (pass);
#     }
#     if (req.http.Authorization || req.http.Cookie) {
#         /* Not cacheable by default */
#         return (pass);
#     }
#     return (lookup);
# }
# 
# sub vcl_pipe {
#     # Note that only the first request to the backend will have
#     # X-Forwarded-For set.  If you use X-Forwarded-For and want to
#     # have it set for all requests, make sure to have:
#     # set bereq.http.connection = "close";
#     # here.  It is not set by default as it might break some broken web
#     # applications, like IIS with NTLM authentication.
#     return (pipe);
# }
# 
# sub vcl_pass {
#     return (pass);
# }
# 
# sub vcl_hash {
#     hash_data(req.url);
#     if (req.http.host) {
#         hash_data(req.http.host);
#     } else {
#         hash_data(server.ip);
#     }
#     return (hash);
# }
# 
# sub vcl_hit {
#     return (deliver);
# }
# 
# sub vcl_miss {
#     return (fetch);
# }
# 
# sub vcl_fetch {
#     if (beresp.ttl <= 0s ||
#         beresp.http.Set-Cookie ||
#         beresp.http.Vary == "*") {
# 		/*
# 		 * Mark as "Hit-For-Pass" for the next 2 minutes
# 		 */
# 		set beresp.ttl = 120 s;
# 		return (hit_for_pass);
#     }
#     return (deliver);
# }
# 
# sub vcl_deliver {
#     return (deliver);
# }
# 
# sub vcl_error {
#     set obj.http.Content-Type = "text/html; charset=utf-8";
#     set obj.http.Retry-After = "5";
#     synthetic {"
# <?xml version="1.0" encoding="utf-8"?>
# <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
# <html>
#   <head>
#     <title>"} + obj.status + " " + obj.response + {"</title>
#   </head>
#   <body>
#     <h1>Error "} + obj.status + " " + obj.response + {"</h1>
#     <p>"} + obj.response + {"</p>
#     <h3>Guru Meditation:</h3>
#     <p>XID: "} + req.xid + {"</p>
#     <hr>
#     <p>Varnish cache server</p>
#   </body>
# </html>
# "};
#     return (deliver);
# }
# 
# sub vcl_init {
# 	return (ok);
# }
# 
# sub vcl_fini {
# 	return (ok);
# }
