---
title: Setting up NixOs on the Lenovo Yoga 11s
date: 2016-02-28
---

I recently decided to do a fresh Linux install, and after some convincing from a [friend of mine](https://github.com/taktoa) about the benefits of 'functional package management', I settled on NixOs. This is a summary of the hardware-specific issues I encountered.

<!-- more -->

## Wireless Drivers
As with any cutting-edge Linux installation, wireless support is nonexistent out of the box. Normally, I would download the appropriate driver package file on a separate machine (i.e. `.deb` / `.rpm`), and install it on the new machine. However, since nixos doesn't have a comparable mobile package format, there's no easy way around this.

You can, however, [build a custom live CD from a configuration.nix file.](https://nixos.org/wiki/Creating_a_NixOS_live_CD) if you already have a working nixos installation. The 11s uses the rtl8192c wireless card from Realtek.

~~~ nix
networking.enableRL8192cFirmware = true;
~~~

In Linux kernel versions after 4.3, generic drivers for Realtek cards were mainlined. I haven't been able to get them to work though, so I just blacklisted the kernel module.

~~~ nix
boot.kernelPackages = pkgs.slinuxPackages_4_4;
boot.blacklistedKernelModules = [ "rtl8xxxu" ];
~~~

## Backlight Timing Issues
Depending on your kernel version, when you press the hardware backlight buttons the backlight may become unresponsive for the next several seconds. The solution to this is to just upgrade to kernel version 4.4 or greater.

You will probably run into the wireless driver issue described above when you do this.

## Terrible Battery Life
This isn't a problem specific to the Yoga 11, but the default settings are absolutely terrible wrt. battery life. This nix expression adds a systemd service to run the powertop auto-tune settings on boot.

~~~ nix
{ config, pkgs, ... }:

{
  config = {
    systemd.services.powertop = {
      description = ''
        enables powertop's reccomended settings on boot
      '';
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ powertop ];

      environment = {
        TERM = "dumb";
      };

      serviceConfig = {
        Type = "idle";
        User = "root";
        ExecStart = ''
          ${pkgs.powertop}/bin/powertop --auto-tune
        '';
      };
    };
  };
}

~~~


This has the downside of automatically enabling power management on USB input devices. The following udev rule should fix that, but it doesn't work automatically. It might be better to follow the advice given in [this forum post](https://bbs.archlinux.org/viewtopic.php?id=201486), and add it to the ExecStart of the nix expression.

~~~ udev
ACTION=="add", SUBSYSTEM=="input", TEST=="power/control", ATTR{power/control}="on"
~~~

