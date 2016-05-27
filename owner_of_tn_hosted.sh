#!/bin/bash

echo -e "\n\n - Checking hosted server now.\n"
su asterisk -c "cd /home/asterisk; export RAILS_ENV=production; ruby /home/asterisk/owner_of_tn.rb $1"
