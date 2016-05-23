#!/bin/bash

echo -e "\n\n!! Enter hosted root password below !!\n\n";
su asterisk -c "cd /home/asterisk; export RAILS_ENV=production; ruby /home/asterisk/owner_of_tn.rb $1"
