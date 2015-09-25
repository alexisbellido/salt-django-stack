# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
# 
# Default backend definition.  Set this to point to your content
# server.
# 

# Managed by saltstack.
{% set settings = salt['pillar.get']('varnish', {}) -%}
{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

backend bk_appsrv_static {
  .host = "{{ zinibu_basic.project.haproxy_frontend_private_ip }}";
  .port = "{{ zinibu_basic.project.haproxy_frontend_port }}";
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

acl purge {
    "localhost";
}

sub vcl_recv {
    # debug bypass
    #return (pass);
    #
    # Health Checking
    if (req.url == "{{ zinibu_basic.project.varnish_check }}") {
        error 751 "health check OK!";
    }

    # Set default backend
    set req.backend = bk_appsrv_static;

    # grace period (stale content delivery while revalidating)
    set req.grace = 30s;
 
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

    # normalize accept-encoding to account for different browsers
    # see: https://www.varnish-cache.org/trac/wiki/VCLExampleNormalizeAcceptEncoding
    if (req.http.Accept-Encoding) {
        if (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {  
            # unknown algorithm  
            remove req.http.Accept-Encoding;
        }
    }


# TODO review
#    # Accept-Encoding header clean-up
#    if (req.http.Accept-Encoding) {
#        # use gzip when possible, otherwise use deflate
#        if (req.http.Accept-Encoding ~ "gzip") {
#            set req.http.Accept-Encoding = "gzip";
#        } elsif (req.http.Accept-Encoding ~ "deflate") {
#            set req.http.Accept-Encoding = "deflate";
#        } else {
#            # unknown algorithm, remove accept-encoding header
#            unset req.http.Accept-Encoding;
#        }
#        
#        # Microsoft Internet Explorer 6 is well know to be buggy with compression and css / js
#        if (req.url ~ ".(css|js)" && req.http.User-Agent ~ "MSIE 6") {
#            remove req.http.Accept-Encoding;
#        }
#    }
#    
#    ### Per host/application configuration
#    # bk_appsrv_static
#    # Stale content delivery
#    if (req.backend.healthy) {
#        set req.grace = 30s;
#    } else {
#        set req.grace = 1d;
#    }
#    
#    # Cookie ignored in these static pages
#    unset req.http.cookie;
#    
#    ### Common options
#    # Static objects are first looked up in the cache
#    if (req.url ~ ".(png|gif|jpg|swf|css|js)(?.*|)$") {
#        return (lookup);
#    }
#    
#    # if we arrive here, we look for the object in the cache
#    return (lookup);
}

# TODO study vcl_hash, hit, miss, etc
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
    # static files always cached 
    if (req.url ~ "^/media" || req.url ~ "^/static") {
       unset beresp.http.set-cookie;
       return (deliver);  
    }

    # TODO should I pass some of this caching of app servers to haproxy?
    # pass through for anything with a session/csrftoken set
    if (beresp.http.set-cookie ~ "sessionid" || beresp.http.set-cookie ~ "csrftoken") {
       return (hit_for_pass);
    } else {
       return (deliver);
    }

#    TODO review
#    # Stale content delivery
#    set beresp.grace = 1d;
#    
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
#    return (deliver);
}

sub vcl_deliver {
    unset resp.http.via;
    unset resp.http.x-varnish;
    # could be useful to know if the object was in cache or not
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
    return (deliver);
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
