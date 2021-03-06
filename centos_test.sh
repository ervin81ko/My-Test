
#!/bin/bash

# Make Synergy cron 
cat << EOF >/etc/cron.d/synergy_cron
*/1 * * * * root /root/synergy_scripts/check_expiration_time.sh
EOF

dest_path=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=dest_path=).*')

# Check expiartion time
cat << 'EOF' >> /root/synergy_scripts/check_expiration_time.sh
#!/bin/bash
# Expiration time in sec. since 1970-01-01 00:00:00 UTC
expiration_time=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json | grep -oP "(?<=\"expiration_time\": \")[^\"]+")

# Time in min.
time_allert=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=syn_allert_clock=).*')

# Current time in sec. since 1970-01-01 00:00:00 UTC
curr_time=$(date -u +%s)

# Compute the difference time in min.
let "time_diff=($expiration_time-$curr_time)/60"

if [ "$time_diff" -le "$time_allert" ]
then
EOF
cat <<EOF>> /root/synergy_scripts/check_expiration_time.sh
    $dest_path
EOF
cat <<'EOF'>> /root/synergy_scripts/check_expiration_time.sh
      if [ $? -eq 0 ]; then 
        rm -rf /etc/cron.d/synergy_cron; 
      fi
else
    echo "Expiration time checked on:" `date` >>/root/synergy_scripts/expiration_time_log.txt
fi
EOF
chmod 755 /root/synergy_scripts/check_expiration_time.sh
