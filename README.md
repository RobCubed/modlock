# modlock

Disable automatic kernel module loading on Linux. Single-file Python 3 script, no dependencies.

## Why

*“In the beginning, modprobe was created. This has made many people very angry and has been widely regarded as a bad move.”* - Douglas Adams

Automatic module loading is a huge and mostly-ignored attack surface. Userspace can poke the kernel into loading ancient, rarely-audited kernel modules on demand. Disabling autoloading can prevent many zero-day vulnerabilities such as [copy.fail](https://copy.fail/)

## How it works

1. Snapshot the currently-loaded modules (`lsmod`) into `/etc/modules` so they get loaded at boot.
2. Write `/bin/true` to `/proc/sys/kernel/modprobe` so the kernel can no longer satisfy userspace module requests.
3. Install a systemd unit that re-applies step 2 on every boot, immediately after `systemd-modules-load.service` processes `/etc/modules`.

**Note:** The kernel has a stronger option (`kernel.modules_disabled=1`) but once set you can't undo it without a reboot. modlock is intentionally reversible.

## Setup

Boot normally. Make sure every device you care about is up and every service you need has started. Modules not loaded at this moment will not be loaded after install.

```
./modlock --setup
```

Done.

## Adding hardware or software later

Anything that wants a new module will fail until you unlock:

```
 modlock --unlock     # autoload back on
# plug / install / configure the new thing
 modlock --update     # capture the expanded module set
 modlock --lock       # autoload off
```

## Commands

| | |
|---|---|
| `modlock --update`    | Snapshot loaded modules → `/etc/modules` (overwrites) |
| `modlock --lock`      | Set `/proc/sys/kernel/modprobe` = `/bin/true` |
| `modlock --unlock`    | Set `/proc/sys/kernel/modprobe` back to the real modprobe |
| `modlock --install`   | Copy script to `/usr/local/sbin/modlock`, install + enable `modlock.service` |
| `modlock --uninstall` | Disable + remove the service, restore autoloading |
| `modlock --setup`     | Run `--update`, `--install`, and `--lock` in sequence |

All commands require root.


## Requirements

Linux with systemd, Python 3, root.
