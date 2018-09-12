# Overview

As we don't have access to GitLab on our salt master, we need a different approach to sync our salt states and pillars:

1) Checkout the repositories on a server with access to GitLab and the saltmaster (currently bs-team server)
2) Push the changes with rsync to the saltmaster
3) Run this periodically e.g. with cron

# Setup
1) Create dir in ``/home/package-bot/saltmaster-cloner ``
2) Clone the states and pillars repositories into this directory with a read only API key (you don't want to have your SSH key on the team server or a read/write token)
3) Copy this script in the ``/home/package-bot/saltmaster-cloner`` directory
4) Make sure the ssh key of the team server is added to the salt master
5) Execute the script periodically with cron: ``*/5 * * * * source /home/package-bot/.bashrc ; cd /home/package-bot/saltmaster-cloner ; ./worker.sh >> /tmp/salt-logger.log 2>&1``
