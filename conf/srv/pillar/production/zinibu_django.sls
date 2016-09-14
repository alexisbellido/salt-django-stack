django:
  lookup:
    # This is the Django project
    # The env variable determines DJANGO_SETTINGS_MODULE used
    env: local
    # using a public Github repository
    repo: git@github.com:alexisbellido/basic-django-project.git
    branch: master
    # using a private repository
    #repo: user@example.com:/home/user/git/basic-django-project.git
    user:
      name: Joe Doe
      email: user@example.com

    # Django-specific packages go here. Always indicate version.
    # A package should have just one of pypi, editable or test_pypi set to True.
    pip_packages:
      django-redis-cache==1.7.0:
        pypi: True
      hiredis==0.2.0:
        pypi: True
      python-dateutil:
        pypi: True
      elasticsearch==2.4.0:
        pypi: True
      django-haystack==2.5.0:
        pypi: True
      django-braces==1.9.0:
        pypi: True
      django-debug-toolbar==1.5:
        pypi: True
      django-allauth==0.27.0:
        pypi: True # the default for production packages from PyPi
      /home/user/djapps/django-zinibu-skeleton:
        editable: True # local source code, useful for development
        repo: user@example.com:/home/user/git/django-zinibu-skeleton.git
        branch: master
      #django-zinibu-skeleton==0.0.2a0:
      #  test_pypi: True # from test PyPi server
