
#!/bin/bash
###########
# Centos7 #
###########

# Synergy directory
mkdir /root/synergy_scripts

# Cron 
cat<< EOF >/etc/cron.d/synergy_cron.txt
*/3* * * * root /root/synergy_scripts/check_expiration_time.sh
EOF
chmod 644 /root/synergy_cron.txt

# Make user script
dest_path=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=dest_path=).*')
cat <<'EOF'>> $dest_path
#!/bin/bash
EOF
row_number=$(curl -s http://169.254.169.254/openstack/latest/user_data |grep -m1 -n 'curl -sL' | sed 's/^\([0-9]\+\):.*$/\1/')
let "from=($row_number+1)"
curl -s http://169.254.169.254/openstack/latest/user_data | tail -n +$from >> $dest_path
chmod 755 $dest_path

# Check expiartion time
cat <<'EOF'>> /root/synergy_scripts/check_expiration_time.sh
#!/bin/bash

# Expiration time in sec. since 1970-01-01 00:00:00 UTC
# expiration_time=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json | grep -oP "(?<=\"expiration_date\": \")[^\"]+")
expiration_time=$(date +%s -d'2017-07-12 12:35:00')

# Time in min.
# time_allert=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=syn_allert_clock=).*')

time_allert=2

# Current time in sec. since 1970-01-01 00:00:00 UTC
curr_time=$(date -u +%s)

# Compute the difference time in min.
let "time_diff=($expiration_time-$curr_time)/60"

if [ "$time_diff" -le "$time_allert" ]
then
     ${$dest_path}
else
      echo "expression evaluated as false nothing to do"
fi
EOF
chmod 755 /root/synergy_scripts/check_expiration_time.sh
