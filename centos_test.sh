
#!/bin/bash
###########
# Centos7 #
###########

# Synergy directory
sudo mkdir /root/synergy_scripts

# Cron 
sudo cat<< EOF >/etc/cron.d/synergy_cron.txt
*/1 * * * * root /root/synergy_scripts/check_expiration_time.sh
EOF
sudo chmod 644 /root/synergy_cron.txt

#Make user script
sudo cat <<'EOF'>> /root/synergy_scripts/user_script.sh
#!/bin/bash
EOF
row_number=$(curl -s http://169.254.169.254/openstack/latest/user_data |grep -m2 -n '#!\/bin\/bash' | sed 's/^\([0-9]\+\):.*$/\1/')
curl -s http://169.254.169.254/openstack/latest/user_data | tail -n +$row_number > /root/synergy_scripts/user_script.sh
sudo chmod 755 /root/synergy_scripts/user_script.sh

#Check expiartion time
sudo cat <<'EOF'>> /root/synergy_scripts/check_expiration_time.sh
#!/bin/bash

#Expiration time in sec. since 1970-01-01 00:00:00 UTC
#expiration_time=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json | grep -oP "(?<=\"expiration_date\": \")[^\"]+")
expiration_time=$(date +%s -d'2017-07-12 12:35:00')

#Time in min.
#time_allert=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=syn_allert_clock=).*')

time_allert=2

#Current time in sec. since 1970-01-01 00:00:00 UTC
curr_time=$(date -u +%s)

#Compute the difference time in min.
let "time_diff=($expiration_time-$curr_time)/60"

if [ "$time_diff" -le "$time_allert" ]
then
      sudo ./user_script.sh
else
      echo "expression evaluated as false nothing to do"
fi
EOF
chmod 755 /root/synergy_scripts/check_expiration_time.sh
