# Django application and stack setup process

The Django setup portion is a manual process. 
This involves setting up with a real, non-sqlite database,
upstreaming with gunicorn, and serving with nginx.
I will be following this as a guide:
 https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-16-04


### Initialize virtualenv
We use the virtualenv to maintain app-specific package dependencies:

```sh
virtualenv -p python3 villapp_env
```

Once we have the virtualenvironment defined we want to activate it while we work:
```sh
source villapp_env/bin/activate
```

Install Django inside the virtualenvironment:

```sh
pip install django==1.10.5 gunicorn psycopg2 djangorestframework
```

___________________________________________________________________________________________
# Postgresql

Log into an interactive database session:

```
$	sudo -u postgres psql
```

Then, create the database that will be used by the application:
```
postgres=# CREATE DATABASE villapp;
```

The user for our database:
Important note: Use a different, non-source controlled password for this user. TIP: You can use lastpass for this.
```
postgres=# CREATE USER dude WITH PASSWORD 'development';
```

We want to make sure of a few specific settings to ensure django/database compatibility.
We want the encoding to be the one django expects. We don't want to read uncommitted transactions, and standardize on UTC for simplicity.
(A lot of time libraries play better with UTC)

```
postgres=# ALTER ROLE dude SET client_encoding TO 'utf8';
postgres=# ALTER ROLE dude SET default_transaction_isolation TO 'read committed';
postgres=# ALTER ROLE dude SET timezone TO 'UTC';
```

Now, we want to grant our dude the ability to make any transaction.

```
postgres=# GRANT ALL PRIVILEGES ON DATABASE villapp TO dude;

```

That's it. We now have a proper postgresql setup. We can quit the interactive command line.

```
postgres=# \q
```

___________________________________________________________________________________________
# Complete Initial Project Setup

Now that we have a working database, we can migrate our database to django's expectations.
Navigate to the directory where you have the manage.py (Project root)

```
python3 manage.py makemigrations
python3 manage.py migrate

```
Now we have our database properly migrated, we can create a superuser with which to do our administration.
This will asks questions about the user like their username, email and password.

```
python3 manage.py createsuperuser

```

When we have added static files to our project we want to collect them under a folder that can be seen and served by nginx. The files (Decided by if they are installed as an app to the greater project) will be assembled into the /static/ directory

```
python3 manage.py collectstatic
```
___________________________________________________________________________________________

# Serve upstream with gunicorn and wsgi:

Serve upstream with gunicorn:
cd /home/ubuntu/mercury/websrc/src/villapp

```
gunicorn --bind 0.0.0.0:9002 villapp.wsgi:application
```

In a production environment we will serve to a socket, which is much better for performance.
As seen in gunicorn.service:

```
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu/mercury/websrc/src/villapp
ExecStart=/home/ubuntu/mercury/websrc/villapp_env/bin/gunicorn --workers 3 --bind unix:/home/ubuntu/mercury/websrc/src/villapp/villapp.sock villapp.wsgi:application

[Install]
WantedBy=multi-user.target
```
nginx will be listening on this socket.

For the development part of things, we will not be using nginx and gunicorn. Gunicorn and nginx cache things hardcore, making it impossible to check changes rapidly.

So, for the development part of things, we should use the built in development server by django.

```
./manage.py runserver 0.0.0.0:9002
```

Port 9002 is forwarded to your hosts' port 80, so you can access it like any other website.

Because we will have domain name checks in django, you want to edit your hosts file on your host computer to point villotec.app to 127.0.0.1

Example:

```
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost

192.168.56.101		doortracker.dev www.doortracker.dev
192.168.56.102		evu.dev	www.evu.dev
127.0.0.1			villapp.dev


```