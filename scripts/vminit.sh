#!/bin/bash
# matt.pestle@nesi.org.nz
# July 2024
#
# Simple script for running a playbook upon VM creation from terraform.
# Put this into the terraform openstack_compute_instance_v2 specification:
#
#  user_data       = templatefile("scripts/vminit.sh",{
#      run_as_user="cloud-user",
#      setup_repo_url="https://github.com/mpestle/vmboot.git",
#      setup_dir="vmboot",
#      setup_playbook="playbook1.yml"
#    }  
#  )
#
# Obviously supply your own repo and playbook within that repo.
# That will download the vmboot repo and run playbook playbook1 from it.
# Timestamped log will be placed in the $HOME directory.
#
# To do:
#    Default run_as_user to {{ ansible_user }}
#    Pass in env variables required for
#          terraform and ansible vault secret retrieval
#
# FWIW: While possibly handy in some cases, I'm not convinced
#       this is a good way to accomplish what we're trying to do here.
#

export TZ=NZ
U=${run_as_user}
me=$(id -u -n)
now=$(date '+%Y%m%d%H%M%S')
LOG_FILE=$HOME/vminit.log.$now

[[ "$me" = "$U" ]] || {
    chmod go+rx "$0"
    echo swapping to $U
    su - $U -c "$0"
    exit
}

exec > $LOG_FILE 2>&1

repo_url=${setup_repo_url}
dir=${setup_dir}
playbook=${setup_playbook}

echo "VM init script"
date
echo -n "run by "
id

echo 
echo repo_url=$repo_url
echo dir=$dir
echo playbook=$playbook

git clone $repo_url || {
    echo Error cloning repository from $repo_url
    exit 1
}
cd $dir || {
    echo Error changing directory to $dir
    exit 1
}
[[ -f "$playbook" ]] || {
    echo Error: No such playbook $playbook
    exit 1
}

ansible-playbook $playbook
