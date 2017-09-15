#!/bin/bash
echo `date`" info: Starting.." >>/root/synergy_scripts/log.txt;

# Create Synergy cron file
cat << EOF >/etc/cron.d/synergy_cron
*/1 * * * * root /root/synergy_scripts/check_expiration_time.sh
EOF
if [ $? -eq 0 ]; then 
  echo `date`" 'info: synergy_cron' file created correctly" >>/root/synergy_scripts/log.txt;
else
  echo `date`" Error:'synergy_cron file not created" >>/root/synergy_scripts/log.txt;
fi

user_script_path=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=user_script_path=).*')
if [ $? -ne 0 ]; then 
  echo `date`" error: 'user_script_path' variable not valorized" >>/root/synergy_scripts/log.txt;
fi
# Create check expiartion time script
cat << 'EOF' >> /root/synergy_scripts/check_expiration_time.sh
#!/bin/bash
# Expiration time in sec. since 1970-01-01 00:00:00 UTC
expiration_time=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json | grep -oP "(?<=\"expiration_time\": \")[^\"]+")

if [ $? -ne 0 ]; then 
  echo `date`" error: 'expiration_time' variable not valorized" >>/root/synergy_scripts/log.txt;
fi
# Time in min.
time_allert=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=syn_allert_clock=).*')
if [ $? -ne 0 ]; then 
  echo `date`" error: 'time_allert' variable not valorized" >>/root/synergy_scripts/log.txt;
fi
# Current time in sec. since 1970-01-01 00:00:00 UTC
curr_time=$(date -u +%s)

# Compute the difference time in min.
let "time_diff=($expiration_time-$curr_time)/60"

if [ "$time_diff" -le "$time_allert" ]
then
EOF
cat <<EOF>> /root/synergy_scripts/check_expiration_time.sh
    $user_script_path
EOF
cat <<'EOF'>> /root/synergy_scripts/check_expiration_time.sh
    if [ $? -eq 0 ]; then 
      echo `date`" info: User script executed correctly" >>/root/synergy_scripts/log.txt;
      rm -rf /etc/cron.d/synergy_cron; 
      echo `date`" info: 'synergy_cron' file removed correctly" >>/root/synergy_scripts/log.txt;
    fi
else
    echo `date`" info: expiration time checked" >>/root/synergy_scripts/log.txt;
fi
EOF
if [ $? -eq 0 ]; then 
  echo `date`" info:'check_expiration_time' script created correctly " >>/root/synergy_scripts/log.txt;
else
  echo `date`" error: 'check_expiration_time' script not created" >>/root/synergy_scripts/log.txt;
fi
chmod 755 /root/synergy_scripts/check_expiration_time.sh
