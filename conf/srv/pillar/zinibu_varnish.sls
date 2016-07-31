varnish:
  # Overrides map.jinja
  lookup:
    value: xxx

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

  # Extra options for varnishd invocation, user and group retired in Varnish 4.1
  extra_options: '-u varnish -g varnish'

  # VCL templates and pillar values used in them
  vcl:
    files:
      - default.vcl
    files_absent:
      - absent.vcl
