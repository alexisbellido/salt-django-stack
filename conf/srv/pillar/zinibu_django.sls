django:
  lookup:
    env: local
    # using a public Github repository
    repo: git@github.com:alexisbellido/basic-django-project.git
    # using a private repository
    #repo: user@example.com:/home/user/git/basic-django-project.git
    user:
      name: Joe Doe
      email: joe@example.com

    # Django-specific packages go here. Always indicate version.
    # A package should have just one of pypi, editable or test_pypi set to True.
    pip_packages:
      django-braces==1.8.1:
        pypi: True
      django-registration==2.0.3:
        pypi: True # the default for production packages from PyPi
      /home/user/djapps/django-zinibu-skeleton:
        editable: True # local source code, useful for development
      django-zinibu-skeleton==0.0.2a0:
        test_pypi: True # from test PyPi server
