#!/bin/bash -e
# this script may need to run with source to switch the virtualenv correctly, like this: $ source thisscript.sh

# Pass the parameter "dev" to start Django's development server.
# thiscript dev
# Pass "production" and "--log-level=LOGLEVEL" to start Gunicorn with a specific log level.
# thiscript production --log-level=debug
# Pass no parameter to start a production setup, like Gunicorn.

#export DJANGO_SETTINGS_MODULE
#export PROJECT_DATABASES_DEFAULT_NAME
#export PROJECT_DATABASES_DEFAULT_USER
#export PROJECT_DATABASES_DEFAULT_PASSWORD
#export PROJECT_DATABASES_DEFAULT_HOST
#export PROJECT_DATABASES_DEFAULT_PORT
#export PROJECT_REDIS_HOST

# user/group to run as
USER={{ user }}
GROUP={{ group }}
export HOME="/home/$USER"

# PROJECTNAME is used by the Python virtual environment, the Django project and the log file.
PROJECTNAME={{ project_name }}
PROJECTDIR=/home/$USER/$PROJECTNAME
PROJECTENV=/home/$USER/pyvenvs/$PROJECTNAME

LOGFILE=/home/$USER/logs/$PROJECTNAME.log
LOGDIR=$(dirname $LOGFILE)

NUM_WORKERS=3
BIND_ADDRESS=192.168.33.15:8000

source $PROJECTENV/bin/activate

cd $PROJECTDIR
export LC_ALL="en_US.UTF-8"

test -d $LOGDIR || mkdir -p $LOGDIR

if [ "$1" == "dev" ]; then
  # development server
  # no need for calling python first for django-admin.py
  echo "==================================="
  echo "Django development server"
  echo "==================================="
  django-admin.py runserver --pythonpath=`pwd` --settings=$PROJECTNAME.settings $BIND_ADDRESS
  # thin wrapper for django-admin.py, no need for --pythonpath or --settings but it requires to use python first
  #python manage.py runserver $BIND_ADDRESS
elif [ "$1" == "production" ]; then
  # production server (gunicorn)
  # see http://docs.gunicorn.org/en/latest/settings.html#loglevel
  # possible values: debug, info, warning, error, critical
  if [ "$2" == "--log-level=debug" ]; then
    LOGLEVEL=debug
  elif [ "$2" == "--log-level=critical" ]; then
    LOGLEVEL=critical
  else
    LOGLEVEL=info
  fi
  gunicorn --workers=$NUM_WORKERS --user=$USER --group=$GROUP --bind $BIND_ADDRESS $PROJECTNAME.wsgi:application --log-level=$LOGLEVEL --log-file=$LOGFILE 2>>$LOGFILE
  # I don't think exec is important anymore here to keep environment variables when running any of the commands with upstart
  #exec gunicorn --workers=$NUM_WORKERS --user=$USER --group=$GROUP --bind $BIND_ADDRESS $PROJECTNAME.wsgi:application --log-level=$LOGLEVEL --log-file=$LOGFILE 2>>$LOGFILE
elif [ "$1" == "collectstatic" ]; then
  echo "==================================="
  echo "Django collect static files"
  echo "==================================="
  django-admin.py collectstatic --pythonpath=`pwd` --settings=$PROJECTNAME.settings --noinput
else
  ## production server (gunicorn) with log to console
  echo "==================================="
  echo "Gunicorn with log to console"
  echo "==================================="
  gunicorn --workers=$NUM_WORKERS --user=$USER --group=$GROUP --bind $BIND_ADDRESS $PROJECTNAME.wsgi:application
fi
