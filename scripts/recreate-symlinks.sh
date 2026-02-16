#!/bin/bash
# Recreate systemd symlinks that were removed for Git compatibility

AIROOTFS="$1"

if [ -z "$AIROOTFS" ]; then
    echo "Usage: $0 <airootfs_path>"
    exit 1
fi

cd "$AIROOTFS"

# Recreate systemd service symlinks
mkdir -p etc/systemd/system/dbus-org.freedesktop.{ModemManager1,network1,resolve1,timesync1}.service
mkdir -p etc/systemd/system/multi-user.target.wants
mkdir -p etc/systemd/system/cloud-init.target.wants
mkdir -p etc/systemd/system/network-online.target.wants
mkdir -p etc/systemd/system/sockets.target.wants
mkdir -p etc/systemd/system/sound.target.wants
mkdir -p etc/systemd/system/sysinit.target.wants
mkdir -p etc/systemd/system-generators

# Multi-user services
ln -sf /usr/lib/systemd/system/choose-mirror.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/hv_fcopy_daemon.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/hv_kvp_daemon.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/hv_vss_daemon.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/iwd.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/livecd-talk.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/ModemManager.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/pacman-init.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/sshd.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/systemd-networkd.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/systemd-resolved.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/vboxservice.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/vmtoolsd.service etc/systemd/system/multi-user.target.wants/
ln -sf /usr/lib/systemd/system/vmware-vmblock-fuse.service etc/systemd/system/multi-user.target.wants/

# Network services
ln -sf /usr/lib/systemd/system/systemd-networkd-wait-online.service etc/systemd/system/network-online.target.wants/

# Socket services
ln -sf /usr/lib/systemd/system/pcscd.socket etc/systemd/system/sockets.target.wants/
ln -sf /usr/lib/systemd/system/systemd-networkd.socket etc/systemd/system/sockets.target.wants/

# Sound services
ln -sf /usr/lib/systemd/system/livecd-alsa-unmuter.service etc/systemd/system/sound.target.wants/

# Sysinit services
ln -sf /usr/lib/systemd/system/systemd-time-wait-sync.service etc/systemd/system/sysinit.target.wants/
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service etc/systemd/system/sysinit.target.wants/

# DBus services
ln -sf /usr/lib/systemd/system/ModemManager.service etc/systemd/system/dbus-org.freedesktop.ModemManager1.service
ln -sf /usr/lib/systemd/system/systemd-networkd.service etc/systemd/system/dbus-org.freedesktop.network1.service
ln -sf /usr/lib/systemd/system/systemd-resolved.service etc/systemd/system/dbus-org.freedesktop.resolve1.service
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service etc/systemd/system/dbus-org.freedesktop.timesync1.service

# Disable gpt-auto-generator (for live environment)
ln -sf /dev/null etc/systemd/system-generators/systemd-gpt-auto-generator

# Create resolv.conf symlink
ln -sf /run/systemd/resolve/stub-resolv.conf etc/resolv.conf

# Create localtime symlink (default to UTC)
ln -sf /usr/share/zoneinfo/UTC etc/localtime

echo "Symlinks recreated successfully!"
