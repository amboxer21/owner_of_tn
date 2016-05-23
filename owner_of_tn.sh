#!/bin/bash

sshpass -p 'LIMA peru 2' ssh nobody@200.255.100.118 "ruby /home/anthony/Documents/Ruby/owner_of_tn.rb $1"
ssh -t aguevara@hosted "bash /home/aguevara/Documents/Bash/owner_of_tn.sh $1"
