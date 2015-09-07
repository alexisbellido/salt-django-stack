# Drupal and Django
# Drupal logic courtesy lullabot
# http://www.lullabot.com/sites/lullabot.com/files/default_varnish3.vcl_.txt

backend drupal_1 {
  .host = "armitage.example.com";
  .port = "8080";
  .probe = {
  .url = "/sites/all/themes/example/i/bullet.png";
  .interval = 5s;
  .timeout = 5s;
  .window = 5;
  .threshold = 3;
  }
}

backend drupal_2 {
  .host = "armitage.example.com";
  .port = "8080";
  .probe = {
  .url = "/sites/all/themes/example/i/bullet.png";
  .interval = 5s;
  .timeout = 5s;
  .window = 5;
  .threshold = 3;
  }
}

# staging
#backend django_1 {
#  .host = "172.16.35.168";
#  .port = "82";
#  .probe = {
#  .url = "/articles/probe";
#  .interval = 5s;
#  .timeout = 5s;
#  .window = 5;
#  .threshold = 3;
#  }
#}
#
#backend django_2 {
#  .host = "172.16.35.168";
#  .port = "82";
#  .probe = {
#  .url = "/articles/probe";
#  .interval = 5s;
#  .timeout = 5s;
#  .window = 5;
#  .threshold = 3;
#  }
#}

# production
backend django_1 {
  .host = "armitage.example.com";
  .port = "82";
  .probe = {
  .url = "/articles/probe";
  #.interval = 5s;
  .interval = 5000000s;
  .timeout = 5s;
  .window = 5;
  .threshold = 3;
  }
}

# debug enable these other two after fixing bugs in app1
#backend django_2 {
#  .host = "web2";
#  .port = "83";
#  .probe = {
#  .url = "/articles/probe";
#  .interval = 5s;
#  .timeout = 5s;
#  .window = 5;
#  .threshold = 3;
#  }
#}
#
#backend django_3 {
#  .host = "web3";
#  .port = "83";
#  .probe = {
#  .url = "/articles/probe";
#  .interval = 5s;
#  .timeout = 5s;
#  .window = 5;
#  .threshold = 3;
#  }
#}

director drupal_balancer round-robin {
 {
 .backend = drupal_1;
 }
 {
 .backend = drupal_2;
 }
}

director django_balancer round-robin {
  {
  .backend = django_1;
  }
# debug enable these other two after fixing bugs in app1
#  {
#  .backend = django_2;
#  }
#  # production has an extra one
#  {
#  .backend = django_3;
#  }
}

# Respond to incoming requests.
sub vcl_recv {
  # use different director for Django based application under /questions, /static or /media
  # uses the Drupal director for everything else
  # notice Varnish sees req.backend as a director.
  if (req.url ~ "^/yte-admin" || req.url ~ "^/accounts/" || req.url ~ "^/api/v1" || req.url ~ "^/sweeps" || req.url ~ "^/questions" || req.url ~ "^/static" || req.url ~ "^/media/"  || req.url ~ "^/dj-admin") {
    set req.backend = django_balancer;
  } else {
    set req.backend = drupal_balancer;
  }

  #set req.backend = drupal_balancer;

  # enable for debugging
  #if (req.url ~ "^/questions" || req.url ~ "^/static" || req.url ~ "^/media/"  || req.url ~ "^/dj-admin") {
  #  return (pass);
  #}
  #return (pass);

  # drop cookies (and respond from cache) if backends are down
  if (!req.backend.healthy) {
    unset req.http.Cookie;
  }

  # serve up stale content if backends don't respond
  set req.grace = 6h;

  # don't cache this
  if (req.url ~ "^/status\.php$" ||
      req.url ~ "^/update\.php$" ||
      req.url ~ "^/ooyala/ping$" ||
      req.url ~ "^/admin/build/features" ||
      req.url ~ "^/info/.*$" ||
      req.url ~ "^/flag/.*$" ||
      req.url ~ "^.*/ajax/.*$" ||
      req.url ~ "^/dj-admin/" ||
      req.url ~ "^/questions/from-external-login/" ||
      req.url ~ "^/experts/search/" ||
      req.url ~ "^.*/ahah/.*$") {
       return (pass);
  }

  #req.url ~ "^/experts/user-register" ||

  # Pipe these paths directly to Apache for streaming.
  if (req.url ~ "^/admin/content/backup_migrate/export") {
    return (pipe);
  }

  if (req.request != "GET" &&
    req.request != "HEAD" &&
    req.request != "PUT" &&
    req.request != "POST" &&
    req.request != "TRACE" &&
    req.request != "OPTIONS" &&
    req.request != "DELETE") {
      /* Non-RFC2616 or CONNECT which is weird. */
      return (pipe);
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

  # Always cache the following file types for all users.
  if (req.url ~ "(?i)\.(png|gif|jpeg|jpg|ico|swf|css|js|htm|html)(\?[a-z0-9]+)?$") {
    unset req.http.Cookie;
  }

  # static and media files always cached 
  if (req.url ~ "^/static" || req.url ~ "^/media") {
    unset req.http.Cookie;
  }

  if (req.restarts == 0) {
    if (req.http.x-forwarded-for) {
        set req.http.X-Forwarded-For =
    	req.http.X-Forwarded-For + ", " + client.ip;
    } else {
        set req.http.X-Forwarded-For = client.ip;
    }
  }

  if (req.request != "GET" && req.request != "HEAD") {
      /* We only deal with GET and HEAD by default */
      return (pass);
  }

  # Strip hash, server doesn't need it.
  if (req.url ~ "\#") {
    set req.url=regsub(req.url,"\#.*$","");
  }

  # Strip out Google related parameters
  if (req.url ~ "(\?|&)(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=") {
    set req.url=regsuball(req.url,"&(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)","");
    set req.url=regsuball(req.url,"\?(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)","?");
    set req.url=regsub(req.url,"\?&","?");
    set req.url=regsub(req.url,"\?$","");
  }

  # Django is setting this cookie so we only check here
  if (req.http.Cookie ~ "LOGGED_IN") {
    return (pass);
  }

  # new lullabot cookies logic
  # Remove all cookies that Drupal doesn't need to know about. ANY remaining
  # cookie will cause the request to pass-through to Apache. For the most part
  # we always set the NO_CACHE cookie after any POST request, disabling the
  # Varnish cache temporarily. The session cookie allows all authenticated users
  # to pass through as long as they're logged in.

  if (req.http.Cookie) {
    set req.http.Cookie = ";" + req.http.Cookie;
    set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
    # replace this original line to include Django's LOGGED_IN
    #set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|NO_CACHE)=", "; \1=");
    set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|NO_CACHE|LOGGED_IN)=", "; \1=");
    set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

    if (req.http.Cookie == "") {
      # If there are no remaining cookies, remove the cookie header. If there
      # aren't any cookie headers, Varnish's default behavior will be to cache
      # the page.
      unset req.http.Cookie;
    }
    else {
      # If there is any cookies left (a session or NO_CACHE cookie), do not
      # cache the page. Pass it on to Apache directly.
      return (pass);
    }
  }
}

# Routine used to determine the cache key if storing/retrieving a cached page.
sub vcl_hash {
  # Include cookie in cache hash.
  # This check is unnecessary because we already pass on all cookies.
  # if (req.http.Cookie) {
  #   set req.hash += req.http.Cookie;
  # }
}

# Code determining what to do when serving items from the web servers.
sub vcl_fetch {
  # Allow items to be stale if needed.
  set beresp.grace = 6h;

  if (req.url ~ "^/api/v1") {
    # this is to control exactly time to caching this url
    set beresp.ttl = 10s;
    return (deliver);
  }

  if (req.url == "/questions/esi-test/") {
     set beresp.ttl = 1s;
     #set beresp.ttl = 5m;
  } else {
     set beresp.do_esi = true; /* Do ESI processing               */
     set beresp.ttl = 24h;
  }

  # Don't allow static files to set cookies.
  if (req.url ~ "(?i)\.(png|gif|jpeg|jpg|ico|swf|css|js|html|htm)(\?[a-z0-9]+)?$") {
    # beresp == Back-end response from the web server.
    unset beresp.http.set-cookie;
  }

  # static and media files always cached 
  if (req.url ~ "^/static" || req.url ~ "^/media") {
     unset beresp.http.set-cookie;
  }

  if (req.url ~ "^/accounts/login" || req.url ~ "^/accounts/register" || req.url ~ "^/accounts/password" || req.url ~ "^/questions/$" || req.url ~ "^/questions/login/" || req.url ~ "^/questions/from-external-login/") {
     return (hit_for_pass);
  }

  # notice Drupal URLs don't have the trailing slash
  # /experts/user-register and /experts/payment-options are needed to fix YTE join problem in Firefox and other Windows browsers
  #if (req.url !~ "^/dj-admin/$" && req.url !~ "^/questions/$" && req.url !~ "^/questions/login/" && req.url !~ "^/questions/from-external-login/" && req.http.Cookie !~ "sessionid" && req.http.Cookie !~ "csrftoken" && req.url !~ "^/user/login" && req.url !~ "^/experts/user-register" && req.http.Cookie !~ "LOGGED_IN" && req.http.Cookie !~ "SESS[a-z0-9]+") {
  if (req.url !~ "^/api/user" && req.url !~ "^/accounts/login" && req.url !~ "^/accounts/register" && req.url !~ "^/accounts/password" && req.url !~ "^/dj-admin/$" && req.url !~ "^/questions/$" && req.url !~ "^/questions/login/" && req.url !~ "^/questions/from-external-login/" && req.http.Cookie !~ "sessionid" && req.http.Cookie !~ "csrftoken" && req.url !~ "^/user/login" && req.url !~ "^/experts/user-register" && req.http.Cookie !~ "LOGGED_IN") {
     unset beresp.http.set-cookie;
     return (deliver);
  } else {
     return (hit_for_pass);
  }
}

# In the event of an error, show friendlier messages.
sub vcl_error {
  # Redirect to some other URL in the case of a homepage failure.
  #if (req.url ~ "^/?$") {
  #  set obj.status = 302;
  #  set obj.http.Location = "http://backup.example.com/";
  #}

  # Otherwise redirect to the homepage, which will likely be in the cache.
  set obj.http.Content-Type = "text/html; charset=utf-8";
  synthetic {"
<html>
<head>
  <title>Page Unavailable</title>
  <style>
    body { background: #303030; text-align: center; color: white; }
    #page { border: 1px solid #CCC; width: 500px; margin: 100px auto 0; padding: 30px; background: #323232; }
    a, a:link, a:visited { color: #CCC; }
    .error { color: #222; }
  </style>
</head>
<body onload="setTimeout(function() { window.location = '/' }, 5000)">
  <div id="page">
    <h1 class="title">Page Unavailable</h1>
    <p>The page you requested is temporarily unavailable.</p>
    <p>We're redirecting you to the <a href="/">homepage</a> in 5 seconds.</p>
    <h4>Debug Info:</h4>
    <pre>Status: "} + obj.status + {" Response: "} + obj.response + {" XID: "} + req.xid + {"</pre>
  </div>
</body>
</html>
"};
  return (deliver);
}

sub vcl_deliver {
  ## cache transparency

  #set resp.http.X-DEBUG-Varnish = "Hey, this is Varnish 3 on staging";
  set resp.http.X-DEBUG-URL = "URL " + req.url;

  #if (req.url ~ "^/experts/user-register") {
  #    set resp.http.X-DEBUG-2 = "this is experts/user-register";
  #}

  if (obj.hits > 0) {
      set resp.http.X-Cache-Varnish = "HIT";
  } else {
      set resp.http.X-Cache-Varnish = "MISS";
  }
}
