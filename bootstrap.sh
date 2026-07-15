# #!/bin/bash

# component=$1
# env=$2
# dnf install -y ansible

# # ansible-pull \
# #   -U https://github.com/pattasai123/ansi_roles_tf.git \
# #   -e component=$component \
# #   main.yaml

# REPO_URL= https://github.com/pattasai123/ansi_roles_tf.git
# REPO_DIR= /opt/roboshop/ansible
# ANSIBLE_DIR= ansi_roles_tf

# mkdir -p /opt/roboshop/ansible
# mkdir -p /var/log/roboshop
# touch ansible.log

# cd $REPO_DIR

# if [-d $ANSIBLE_DIR ]; when

#   cd $ANSIBLE_DIR
#   pull $REPO_URL

# else 
#   git clone $REPO_URL
#   cd $ANSIBLE_DIR

# if

# ansible-playbook -e component=$component -e env=$env main.yaml

#!/bin/bash

component=$1
env=$2

dnf install -y ansible git

REPO_URL="https://github.com/pattasai123/ansi_roles_tf.git"
REPO_DIR="/opt/roboshop/ansible"
ANSIBLE_DIR="ansi_roles_tf"

mkdir -p "$REPO_DIR"
mkdir -p /var/log/roboshop
touch /var/log/roboshop/ansible.log

cd "$REPO_DIR" || exit 1

if [ -d "$ANSIBLE_DIR" ]; then
    cd "$ANSIBLE_DIR" || exit 1
    git pull
else
    git clone "$REPO_URL"
    cd "$ANSIBLE_DIR" || exit 1
fi

ansible-playbook \
    -e component="$component" \
    -e env="$env" \
    main.yaml

