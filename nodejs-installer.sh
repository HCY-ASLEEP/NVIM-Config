nodejs_version='node-v18.15.0-linux-x64'
nodejs_pack=$nodejs_version".tar.xz"
sudo curl -L https://npmmirror.com/mirrors/node/v18.15.0/$nodejs_pack -o /opt/$nodejs_pack
sudo tar -xvf /opt/$nodejs_pack -C /opt/
sudo mv /opt/$nodejs_version /opt/nodejs
sudo rm /opt/$nodejs_pack
sudo sh -c 'echo "\nexport PATH=\$PATH:/opt/nodejs/bin/" >> /etc/bash.bashrc'
. /etc/bash.bashrc
npm config set registry https://registry.npm.taobao.org
npm i -g yarn
unset nodejs_version
unset nodejs_pack
