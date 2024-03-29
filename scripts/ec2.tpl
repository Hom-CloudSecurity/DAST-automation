#!/bin/bash
cat <<EOF >/home/ubuntu/user-data.sh
#!/bin/bash
wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
sudo cp jq /usr/bin
curl --request POST 'https://api.github.com/repos/Hom-CloudSecurity/DAST-automation/actions/runners/registration-token' --header "Authorization: token ${personal_access_token}" > output.txt
runner_token=$(jq -r '.token' output.txt)
mkdir actions-runner
cd actions-runner
curl -o actions-runner-linux-x64-2.294.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.294.0/actions-runner-linux-x64-2.294.0.tar.gz
tar xzf actions-runner-linux-x64-2.294.0.tar.gz
rm actions-runner-linux-x64-2.294.0.tar.gz
./config.sh --url https://github.com/Hom-CloudSecurity/DAST-automation --token $runner_token --name "Github EC2 Runner" --unattended
./run.sh
EOF
cd /home/ubuntu
chmod +x user-data.sh
screen -S Sankat
/bin/su -c "./user-data.sh" - ubuntu | tee -i /home/ubuntu/user-data.log
