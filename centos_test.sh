#!/bin/bash
sudo mkdir /root/synergy_scripts 
# Synergy cron
sudo cat<< EOF >/etc/cron.d/synergy_cron.txt
*/1 * * * * root /root/synergy_scripts/check_expiration_time.sh
EOF
sudo chmod 644 /etc/cron.d/synergy_cron.txt

#Check expiartion time
sudo cat <<'EOF'>> /root/synergy_scripts/check_expiration_time.sh
#!/bin/bash
expiration_date=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json | grep -oP "(?<=\"expiration_date\": \")[^\"]+")
syn_allert_clock=$(curl -s http://169.254.169.254/openstack/latest/user_data | grep -m1 -oP '(?<=syn_allert_clock=).*')
echo $syn_allert_clock > /root/synergy_scripts/pippo.txt
echo $expiration_date > /root/synergy_scripts/pluto.txt
EOF
sudo chmod 755 /root/synergy_scripts/check_expiration_time.sh
