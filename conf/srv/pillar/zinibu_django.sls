django:
  lookup:
    env: local
    repo: git@github.com:alexisbellido/basic-django-project.git
    user:
      name: Joe Doe
      email: joe@example.com.com
    # Django-specific packages go here
    # From PyPi
    pip_packages:
      - Django==1.8.7
    # From local source, used in development
    pip_editable_packages:
      - /home/user/djapps/django-zinibu-skeleton
    # From test PyPi
    #pip_test_packages:
    #  - django-zinibu-skeleton==0.0.2a0
