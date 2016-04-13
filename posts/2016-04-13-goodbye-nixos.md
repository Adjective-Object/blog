---
title: Goodbye, Nixos
tags: nix, nixos
---

NixOs is a great idea, but after 2 and a half months of using it as my primary OS, I've decided to give up on it for the time being. This is a rough summary of my reasons:





## Nix is Immature, Slow, and Unusable

I think this is one of the biggest problems with nixos. There seem to be some _questionable_ design decisions made in the core of the nix package manager, mostly stemming from the principled 'stateless / functional' approach nix wants to take.

The biggest issue I have is that nix performs no caching of the derivations of a repository.This, coupled with the way most users want to query packages (by name, not by attribute path) means that _every package_ has to be re-evaluated on every package install.

The community approach to this problem is to use [`nox`](https://github.com/madjar/nox), a wrapper around nix that caches  the derivation made by fully evaluating a nix channel. However, this cache only lasts an hour, and has no relationship with the nix channel it's derived from.

### tldr 

 - there is no good caching implementation
 - packages are hard to find
 - the command line interface is bad



## All Software is Broken, Mostly in the Build Process

Because most distributions of Linux make similar decisions wrt where to put packages & where to put include files, a lot of software can get away with being silently broken, and still build without issue on these distributions.

For example, the build proces of the `godot` engine completely ignores the pkg-config path in the environment, yet still uses pkg-config internally. On most systems, this is fine, since the default pkg config path will contain all the right header & library directories. However, because nixos puts everything in the nix store, this can never work on nixos.

Another example is in the outputs of `mesa-gdm`. It's pkg-config files don't actually provide the path to it's header directories. Once more this path would normally be provided by the default pkg-config path on another distribution (i.e. `/usr/include/..` ), but could never work on nixos without the pkg-config files being fixed

### tldr

 - NixOS is a special snowflake that depends on contracts that most software accidentally breaks.



## Non-Free Software
Most professionally developed applications treat Linux as a second or third-class operating system. As annoying as this is, it's hard to fault most companies for doing this -- There simply isn't enough adoption to make prioritizing :inux support worthwhile. Most of the time, we only get support for the latest release of Ubuntu or Fedora. Moreover, most builds will be provided as binaries only, as the projects are for-profit and closed source.

While a binary distribution isn't that much of an issue thanks to `patchelf`, Software distributed like this comes with a host of other issues, like hard-coded paths specific to ubuntu / fedora.

Once more, it's not as if the fixes for this are computationally expensive, they just have not been implemented yet in most cases. Moreover, it's hard to implement these fixes on the binary distributions.


### tldr

 - Try running non-free software on nix, I dare you.

## Advantages of Nix
I will say that the nix-shell mechanism has provided one of the nicest development environment experience I've had. However you can get that installed on top of a well-supported operating system.


## Conclusions

NixOS is too beautiful for this ugly world. I'm switching to xubuntu + nix.

（ つ Д ｀）.
