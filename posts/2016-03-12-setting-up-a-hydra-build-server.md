---
title: Setting up a Hydra Build Server on a Raspberry Pi
tags: packaging, hydra, nix, nixos, integration
      example
---

[tl;dr](#workaround---using-debian) If you don't care about my ramblings and 
just want the process.

# Overview

In my continuing adventures with nixos, I wanted to try out the nix-based build
server, Hydra. The main selling pitch of Hydra is that it takes advantage of 
the granular  environment control in nix to automatically perform re-produceable 
builds and tests.

As the only computer I currently have access to apart from my laptop is a
raspberry pi, that's what I decided to try to set it up on.

<!-- more -->

# What not to do
My first approach was to use one of the pre-built nixos images for the raspberry
pi, and install hydra as a nixos service on top of that. However, as far as I
can tell, there is no working binary cache for arm6 devices for nixpkgs. 

Moreover, the current state of cross-architecture compilation in nixos is a
bit of a mess as far as I can tell. My normal backup strategy for getting
software I need on my pi is to cross-compile it on a better machine, and
then move the build products over manually.

This meant that I had to build all non-default-included images from source,
which was a non-option, as just compiling git resulted in an out-of-memory
error on the Pi. (The most up to date images I could find were the
minimal images [linked on the wiki](https://nixos.org/wiki/NixOS_on_ARM)).

(As a side note, A friend of mine is running a nixpkgs binary cache, but the
last time I checked the builds were failing.)

Overall, it seems like the current state of NixOS on ARM is extremely immature.


# Workaround - Using Debian
As it turns out, you can install Hydra on top of Debian without much issue,
so you can take advantage of the mature Debian packaging environment.

1. Get the RPi foundation's 
    [Minimal Raspberry Pi Image][min-pi-img]

2. Install the Nix and Hydra dependencies.

    ~~~ bash
    ❯ sudo apt-get install TODO
    ~~~
3. Download the Nix package manager and install it from source.

    ~~~ bash
    ❯ git clone  [ TODO WRITE THIS PART ]
    ~~~

    This'll take a while. Grab a beer and go watch your stories.

4. Set up the nixbld user and user group

    ~~~ bash
    ❯ useradd nixbuilder -G nixbld
    ~~~

5. Download and install hydra from source. Because hydra's `master` branch
    is sometimes broken, you need to find the most recent passing build
    of hydra on the 
    [nixos hydra build server](http://hydra.nixos.org/jobset/hydra/master)

    at the time of writing, this is hydra @ 
    [993647d][working-hydra-revis]

    ~~~ bash
    # get the revision
    ❯ mkdir hydra-git
    ❯ cd hydra-git
    ❯ git init
    ❯ git remote add origin https://github.com/NixOS/hydra.git
    ❯ git fetch origin 993647d1e3b43f1f9b7dc2ebce889b475d156bb9
    ❯ git reset --hard FETCH_HEAD

    # build it
    ❯ ./bootstrap
    ❯ ./configure
    ❯ make
    ❯ sudo make install
    ~~~

    While this is building you can proceed through the rest of the
    configuration steps.

6. Set up postgres to accept hydra, roughly following the 
    [guide on the wiki][hydra-install-guide].

    ~~~ bash
    ❯ sudo -u postgres createuser hydra -P
        Enter password for new role: 
        Enter it again: 
        Shall the new role be a superuser? (y/n) n
        Shall the new role be allowed to create databases? (y/n) n
        Shall the new role be allowed to create more new roles? (y/n) n
    ❯ sudo -u postgres createdb -O hydra hydra
    ❯ mkdir ~/hydra   
    ~~~

7. Inform hydra of how to find the postgres server

    ~~~ bash
    ❯ echo "export HYDRA_DBI=\"dbu:Pg:dbname=hydra;host=localhost;user=hydra\"" >> ~/.profile
    ❯ echo "export HYDRA_DATA=\"$HOME/hydra\"" >> ~/.profile
    ~~~

    Note that we do not need to tell postgres to use md5 hashes to check for
    uniqueness, since it defaults to this in the most recent postgres
    version available on debian as of the time of writing (9.4)

8. thing



[min-pi-img]: https://nixos.org/wiki/Installing_Hydra_on_Ubuntu
[hydra-install-guide]: https://nixos.org/wiki/Installing_Hydra_on_Ubuntu
[working-hydra-revis]: https://github.com/NixOS/hydra/commit/993647d1e3b43f1f9b7dc2ebce889b475d156bb9

