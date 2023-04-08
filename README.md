This my neovim config.

</br>

To use neovim config with coc.nvim, you can download files to your customized path or run the following one-line command:

```bash
curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config.sh | sh
```
</br>

To use neovim config without coc.nvim but with self-contained auto completion of vim, and can also edit markdown at the same time, you can download files to your customized path or run the following one-line command:

```bash
curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config-without-coc.nvim/nvim-config.sh | sh
```
</br>

To install latest nodejs of coc.nvim in China, you can run the following one-line command, but before running the command I strongly recommand switching to a non-root user firstly:

```bash
curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/coc-nodejs-installer.sh | bash
```

</br>

To quickly config your neovim develop environment in docker ubuntu, after enter the bash shell of docker ubuntu, you can try these commands:

```bash
apt update;\
    apt upgrade -y;\
    apt install neovim xz-utils curl sudo git apt-transport-https ca-certificates -y;\
    useradd -m devenv;\
    usermod -s /bin/bash devenv;\
    sudo sh -c 'echo "devenv ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers';\
    sudo chown devenv /home/devenv/;\
    sudo chgrp devenv /home/devenv/;\
    su devenv
```

</br>

To config all what coc.nvim need of the docker ubuntu in one step:

```bash
apt update;\
    apt upgrade -y;\
    apt install neovim xz-utils curl sudo git apt-transport-https ca-certificates -y;\
    useradd -m devenv;\
    usermod -s /bin/bash devenv;\
    sudo sh -c 'echo "devenv ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers';\
    sudo chown devenv /home/devenv/;\
    sudo chgrp devenv /home/devenv/;\
    su -c 'curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config.sh | sh' devenv;\
    su -c 'curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/coc-nodejs-installer.sh | bash' devenv;\
    su devenv
```

```bash
curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh;\
    sh ~/miniconda.sh -b';\
    rm ~/miniconda.sh
```
