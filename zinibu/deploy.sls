deploy-django-project:
  salt.state:
    - tgt: 'roles:webhead'
    - tgt_type: grain
    - sls:
      - zinibu.django
    - pillar: {'deploy': True }

deploy-django-packages:
  salt.state:
    - tgt: 'roles:webhead'
    - tgt_type: grain
    - sls:
      - zinibu.django.conf
    - pillar: {'deploy': True }

# TODO pass a variable from bash to determine what should be deployed,
# possible choices: everything (default), just project, just packages, one or more packages (passed as list)

# This can receive pillar data from command line like this:
# sudo salt-run state.orchestrate zinibu.deploy pillar='{"project_branch": "master"}'
# and then state can use that like this:
#{{ salt['pillar.get']('project_branch', '') }} 

#deploy-function:
#  salt.function:
#    - name: cmd.run
#    - tgt: 'roles:webhead'
#    - tgt_type: grain
#    - arg:
#      - echo "TEST RUN WEBHEAD COMMAND deploy"
