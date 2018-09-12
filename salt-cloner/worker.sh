echo "=========================================================="
echo "Start salt update script $(date)"
echo 'Updating salt states ...'
cd 'salt-states-obs'
git fetch origin
git rebase origin/master
rsync -Pav --delete -e "ssh -i /home/package-bot/.ssh/id_rsa -p 2210" /home/package-bot/saltmaster-cloner/salt-states-obs/ root@proxy-opensuse.suse.de:/srv/salt

cd ..

echo 'Updating salt pillars ...'
cd 'salt-pillars-obs'
git fetch origin
git rebase origin/master
rsync -Pav --delete -e "ssh -i /home/package-bot/.ssh/id_rsa -p 2210" /home/package-bot/saltmaster-cloner/salt-pillars-obs/ root@proxy-opensuse.suse.de:/srv/pillar
echo "Finished update script $(date)"
echo "=========================================================="

