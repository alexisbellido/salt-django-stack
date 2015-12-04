django:
  lookup:
    env: local
    repo: git@github.com:alexisbellido/basic-django-project.git
    user:
      name: Joe Doe
      email: joe@example.com

    # Django-specific packages go here. Always indicate version.
    pip_packages:
      Django==1.8.7:
        pypi: True # the default for production packages from PyPi
      /home/user/djapps/django-zinibu-skeleton:
        editable: True # local source code, useful for development
      django-zinibu-skeleton==0.0.2a0:
        test_pypi: True # from test PyPi server
