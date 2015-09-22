varnish:
  # Overrides map.jinja
  lookup:
    version: xxx

  # List of storage backends
  storages:
    - 'main=malloc,512m'
    - 'secondary=malloc,256m'

  # Parameters to be set on start with the -p param=value option
  params:
    default_ttl: 120
    default_grace: 10
    thread_pool_min: 50
    thread_pool_max: 1000
    thread_pool_timeout: 120

  # Extra options for varnishd invocation
  extra_options: '-u varnish -g varnish'

  # VCL templates and pillar values used in them
  vcl:
    version: '3.0'
    backend_default_host: 10.1.1.1
    backend_default_port: 80
    files:
      - default.vcl
    files_absent:
      - absent.vcl
