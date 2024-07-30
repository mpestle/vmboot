Example of fitting out a new VM with an ansible
playbook in conjunction with vminit.sh and 
user_data of a terraform definition:

resource "openstack_compute_instance_v2" "whatever" {
  name            = whatever ...
  flavor_id       = whatever ...
  image_id        = whatever ...
  key_pair        = whatever ...
  user_data       = templatefile("scripts/vminit.sh",{
      run_as_user="cloud-user",
      setup_repo_url="https://github.com/mpestle/vmboot.git",
      setup_dir="vmboot",
      setup_playbook="playbook1.yml"
    }  
  )
}

The image you are using must have git and ansible installed.

vminit.sh clones the repo, cds into the setup_dir, and runs the playbook.
