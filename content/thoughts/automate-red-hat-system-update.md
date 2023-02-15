+++
title = "Automate RedHat system update"
date = "2023-02-15"
+++

I manage several build machines for my own personal use, and in an effort to reduce the maintenance burden I've decided to automate the system update process.

A requirement I have for the automation is that the system should reboot after each update, no matter what have been updated, but only when one or more packages have been updated. This is to ensure that the system can still boot.

The build machines uses a variant of the Red Hat Linux distribution, i.e. it uses `dnf` as the package manager. With `dnf` we can check whether we have pending updates (something similar should be available for other package managers).

```shell
dnf check-update
```

The `check-update` subcommand will use `100` as the exit code when pending updates are available, otherwise it will exit with `0` (as long as everything was successful).

With this knowledge we can schedule a cronjob on the machine, that will run an update and reboot the system, but only when packages have been updated. 

```shell
dnf check-update -y; [[ $? -eq 100 ]] && dnf update -y && reboot
```

The `$?` variable will contain the exit code of the latest executed command, i.e. the exit code of the `dnf check-update -y` command. And, if the exit code is `100` we start an update and then reboot the system.

Depending on the other workload on the machine, it might be a good idea to gracefully shut down other services before updating the system, e.g. shut down the Docker daemon to prevent the applications to suddenly lose the firewall rules or network routing.

Also, if a system can automatically be rebooted, the workload should be scheduled to start when the machine has been booted.

In my case, as the machine is not running any production workload and the necessary services are scheduled to start on boot, a simple cronjob is good enough.
