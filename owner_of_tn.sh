#!/bin/bash

if [[ $# != 1 ]]; then
  echo -e "\n => Usage: ./owner_of_tn.rb <telephone number>\n";
  exit;
fi

sshpass -p 'FXXXxxxxxxxxx' ssh nobody@200.255.xxx.xxx "/bin/ruby /home/nobody/Documents/Ruby/owner_of_tn.rb $1"
sshpass -p '' s4gxxxxxxx'  ssh -t aguevara@hosted "bash /home/aguevara/Documents/Bash/owner_of_tn.sh $1"
