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
which was a non-option. (The most up to date images I could find were the
minimal images [linked on the wiki](https://nixos.org/wiki/NixOS_on_ARM))

(As a side note, A friend of mine is running a nixpkgs binary cache, but the
last time I checked the builds were failing.)

Overall, it seems like the current state of NixOS on ARM is extremely immature.


# Workaround - Using Debian
As it turns out, you can install Hydra on top of Debian without much issue,
so you can take advantage of the mature Debian packaging environment.

 1. Get the RPi foundation's 
    [Minimal Raspberry Pi Image][min-pi-img]
 2. Install the Nix and Hydra dependencies.
    
        sudo apt-get install TODO
    
 3. Download the Nix package manager and install it from source.

        git clone  [ TODO WRITE THIS PART ]

    This'll take a while. Grab a beer and go watch your stories.

 4. Download and install hydra, following the 
    [guide on the wiki][hydra-install-guide].



[min-pi-img]: https://nixos.org/wiki/Installing_Hydra_on_Ubuntu
[hydra-install-guide]: https://nixos.org/wiki/Installing_Hydra_on_Ubuntu

