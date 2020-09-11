#!/usr/bin/bash env

ansible-playbook \
    --connection=local \
    --inventory 127.0.0.1, \
    --limit 127.0.0.1 \
    -i ansible_hosts \
    gccemacs-playbook.yml
