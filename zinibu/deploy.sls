#TODO go over project and django apps and see if I can target all by default or just some

deploy-state:
  salt.state:
    - tgt: 'roles:webhead'
    - tgt_type: grain
    - sls:
      - zinibu.django
    - pillar: {'deploy': True }

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
