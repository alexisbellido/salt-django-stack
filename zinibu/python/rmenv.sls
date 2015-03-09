remove_pyvenv:
  cmd.run:
    - cwd: {{ salt['pillar.get']('python:pyvenvs_dir', '/home/user/pyvenvs') }}
    - user: {{ salt['pillar.get']('zinibu_common:app_user', 'user') }}
    - group: {{ salt['pillar.get']('zinibu_common:app_user', 'group') }}
    - shell: /bin/bash
    - name: rm -rf {{ salt['pillar.get']('python:pyvenv_name', 'venv') }}
