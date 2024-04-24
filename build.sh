#!/usr/bin/env bash

set -eu

TMPDIR_BASE=$(dirname $(mktemp -u))

date

cd terraform
terraform init
terraform validate
terraform plan -out $TMPDIR_BASE/terraform-plan.tf
terraform apply $TMPDIR_BASE/terraform-plan.tf
cd ..

cd terraform
HOST=$(terraform output -raw public_ip)
cat <<EOF > ../ansible/inventory.ini 
[servers]
$HOST
EOF
cd ../ansible

# do not use -e as ssh fails multiple times before it is available
set +e

MAX_RETRIES=10
RETRY_DELAY=5
attempt=0
while [ $attempt -lt $MAX_RETRIES ]; do
    result=$(ssh -o StrictHostKeyChecking=no -q admin@$HOST true)
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "SSH is available on $HOST with user admin after $attempt attempts."
        break
    fi
    attempt=$((attempt + 1))
    echo "SSH not available on attempt $attempt. Retrying in $RETRY_DELAY seconds..."
    sleep $RETRY_DELAY
done
if [ $attempt -eq $MAX_RETRIES ]; then
    echo "Failed to connect to SSH on $HOST after $MAX_RETRIES attempts."
    exit 1
fi

set -e

export REGISTRY_USER=oli
export REGISTRY_PASSWORD=xxx
export GITHUB_TOKEN=xxx
ansible-playbook -i inventory.ini playbook.yml
cd ..

cd terraform
terraform destroy -auto-approve
cd ..

date
