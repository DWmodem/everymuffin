Install Process: (Rough draft)

First and foremost, this is the kind of tutorial where you're allowed to think.
If something is fishy or doesn't make sense, it's probably because it's wrong or
there is something fundamentally wrong with reality.

### Basic Setup 

On your HOST machine:

Install cygwin (You'll need loads of packages, such as ssh and other helpful tools)
Install Virtualbox (https://www.virtualbox.org/)
Install Ruby (https://www.ruby-lang.org/en/downloads/)
Install Vagrant (https://www.vagrantup.com/downloads.html)

Open up a cygwin terminal and change the directory to the one containing the vagrant file:
``` $	cd /cygdrive/c/<path_to_mercury>/devops/

Bring up virtual machine:

```$	vagrant up

It might take a while if it has to download a virtual machine image.

Once this is done, ssh into virtual machine:

```$	vagrant ssh

### Using our own public key

Generate your ssh key without a passphrase
Add in your own public key to authorized hosts:

```$	vim ~/.ssh/authorized_keys
	*paste in your key*

Port 22 is forwarded to 127.0.0.1:2222.

So, to ssh into the machine:

```$	ssh ubuntu@127.0.0.1:2222 -i ~/.ssh/id_rsa_villotec_phil

I've used my own key here but obviously use your own.
To avoid having to type all that out (Or use vagrant ssh, which does not work everywhere)
Have a ~/.ssh/config (inside your LOCAL machine) containing the following:

/home/{YOUR USER}/.ssh/config
```
Host va
    Hostname 127.0.0.1
    Port 2222
    IdentityFile ~/.ssh/id_rsa_villotec_phil
    User ubuntu
```

You will subsequently be able to ssh into your dev machine using:
```$	ssh va


If you have a windows machine I suggest you run git from your virtualmachine. 
In which case you will need to add your current or a new github private key to the VM's .ssh folder.

/home/ubuntu/.ssh/config
```
Host github.com
    HostName github.com
    IdentityFile ~/.ssh/github_rsa
    User git
```

/home/ubuntu/.ssh/github_rsa
```
{your github private key}

```
And from there, you will be all set up to be able to work on the application once you clone the mercury project.

```$	git clone git@github.com:acourt/mercury.git


When you commit anything you've edited using a windows based development environment, please make sure to use unix line endings.
You'll see them light up when you do 

```$	git diff


### Bootstraping the Dev environment

First we want to do the boostrapping of our development environment.
From your host machine I will assume you already have the mercury project cloned (And on a relevant branch)

Copy over the devops/.bootstrappackage folder to the virtual machine. There are in here all the files we will need to initiate our environment.

scp -rp .bootstrappackage va:~/.bootstrappackage

Once the package is there, cd into is from an ssh tunnel:

```$	ssh va
```$	cd ~/.bootstrappackage

And from here run 

```$	sudo ./bootstrap.sh

And bootstrap will initialize the necessary files and binaries needed to work efficiently.



### Unison Syncroniser

To be able to work on a remote computer while using our local machine as a IDE and a development tool, we use Unison (https://www.cis.upenn.edu/~bcpierce/unison/)
(bootstrap.sh should have installed it. If it ran, everything should be done for the ubuntu server side of things.)

Linux binaries (tared and compressed):
http://everyunison.com/static/ubinaries/unison2.48.3-64bit-ocaml4.01.0-ubuntu14.04/unison2.48.3-64bit-ocaml4.01.0-ubuntu14.04.tar.gz

Windows binaries (tared and compressed):
http://everyunison.com/static/ubinaries/unison2.48.3-64bit-ocaml4.01.0-windows10/unison2.48.3-64bit-ocaml4.01.0-windows10.tar.gz

Make both unison, and fsmonitor available on your PATH.
We now want to make a unison profile to sync the two machines continuously. While it is possible to call unison from the command line every time,
you will be better served from a profile that will keep track of which roots (folders) you want to keep in sync.

Here are the contents of my profile:

{YOUR USER}/.unison/default.prf
```
# Unison preferences file
root = C:/Users/phili/Documents/django/mercury
root = ssh://va/mercury

fastcheck = true

ignore = Path .git
```

Obviously you'll want to use the root of where your project is rather than mine.

To syncronize roots,
call
```$	unison

This will allow you to choose which files to keep as truth if some have differences from one side to the next.
Then you can use:
```$	unison -repeat watch -auto

This will make unison watch for changes and apply them to whichever side needs them. 
This is the command you use for during development time.
