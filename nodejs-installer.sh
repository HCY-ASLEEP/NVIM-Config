cd ~
latest_version=$(curl -sL https://nodejs.org/en/download/ | grep -o -E 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
download_url="https://nodejs.org/dist/$latest_version/node-$latest_version-linux-x64.tar.xz"
install_dir="/opt/nodejs"
sudo mkdir $install_dir
sudo chown -R devenv $install_dir
sudo chgrp -R devenv $install_dir
curl -o nodejs.tar.xz $download_url
tar -xf nodejs.tar.xz -C $install_dir
sudo sh -c 'echo "\nexport PATH=\$PATH:\$install_dir/node-\$latest_version-linux-x64/bin/" >> /etc/bash.bashrc'
rm nodejs.tar.xz
. /etc/bash.bashrc
export PATH=$PATH:$install_dir/node-$latest_version-linux-x64/bin/
npm config set registry https://registry.npm.taobao.org
npm config set registry https://registry.npm.taobao.org
npm i -g yarn
unset latest_version
unset download_url
unset install_dir
bash
echo "---- Node.js $latest_version installed ----"
