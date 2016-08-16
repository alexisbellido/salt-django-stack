# TODO pass a variable from bash to determine what should be deployed,
# possible choices: everything (default), just project, just packages, one or more packages (passed as list)

{% set deploy_target = salt['pillar.get']('deploy_target', '') %}

{% if deploy_target == 'project' %}
deploy-django-project:
  salt.state:
    - tgt: 'roles:webhead'
    - tgt_type: grain
    - sls:
      - zinibu.django
    - pillar: {'deploy': True, 'deploy_target': {{ deploy_target }} }
{% endif %}

{% if deploy_target == 'apps' %}
deploy-django-packages:
  salt.state:
    - tgt: 'roles:webhead'
    - tgt_type: grain
    - sls:
      - zinibu.django.conf
    - pillar: {'deploy': True, 'deploy_target': {{ deploy_target }} }
{% endif %}

#deploy-function:
#  salt.function:
#    - name: cmd.run
#    - tgt: 'roles:webhead'
#    - tgt_type: grain
#    - arg:
#      - echo "TEST RUN WEBHEAD COMMAND deploy"
