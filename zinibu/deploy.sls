deploy-state:
  salt.state:
    - tgt: 'roles:webhead'
    - tgt_type: grain
    - sls:
      - zinibu.django
    - pillar: {'deploy': True, 'project_branch': {{ salt['pillar.get']('project_branch', '') }} }

#deploy-function:
#  salt.function:
#    - name: cmd.run
#    - tgt: 'roles:webhead'
#    - tgt_type: grain
#    - arg:
#      - echo "TEST RUN WEBHEAD COMMAND"
