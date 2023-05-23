This my neovim config.


[国内 Gitee 加速 (并不是单纯的仓库克隆，而是把所有需要的源都换成了国内的)](https://gitee.com/mygiteehcy/NVIM-Config/tree/main/)



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
    apt install neovim xz-utils curl sudo git apt-transport-https ca-certificates ripgrep-y;\
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
    apt install neovim xz-utils curl sudo git apt-transport-https ca-certificates ripgrep -y;\
    useradd -m devenv;\
    usermod -s /bin/bash devenv;\
    sudo sh -c 'echo "devenv ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers';\
    sudo chown devenv /home/devenv/;\
    sudo chgrp devenv /home/devenv/;\
    su -c 'curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config.sh | sh' devenv;\
    su -c 'curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/coc-nodejs-installer.sh | bash' devenv;\
    su devenv
```

</br>

To edit nvim config easily, you can:

```bash
echo "alias iv = 'nvim ~/.config/nvim/init.vim'" >> ~/.bashrc
echo "alias v = 'nvim" >> ~/.bashrc
```

</br>

***

</br>

To install miniconda of docker ubuntu in China, you must 'su devenv' first!!! Then exec follows: 
```bash
curl https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh;\
    sh ~/miniconda.sh -b;\
    rm ~/miniconda.sh;\
    ~/miniconda3/bin/conda init bash;\
    sed -n '/# >>> conda initialize >>>/,/# <<< conda initialize <<</p' ~/.bashrc >> ~/.condainit;\
    sed -i '/# >>> conda initialize >>>/,/# <<< conda initialize <<</d' ~/.bashrc;\
    echo 'alias cab="source ~/.condainit"' >> ~/.bashrc;\
    . ~/.bashrc
```
Then you can activate the conda env using 'cab' ( alias of 'conda activate base' )

</br>

To use fcitx input methed in GUI programes of the container, you can run commands below:

```bash
sudo sh -c 'echo "\nexport GTK_IM_MODULE=fcitx\nexport QT_IM_MODULE=fcitx\nexport XMODIFIERS=@im=fcitx\n" >> /etc/bash.bashrc';\
    . /etc/bash.bashrc
```

However, fcitx may still not work in QT programes of the container. I had met this problem in xfce4 host environment, anyone has solutions can commit an issue, thanks.

</br>

Here are configs of my host .bashrc:
```bash
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

alias p='export ALL_PROXY=socks5://127.0.0.1:7890'
alias np='unset ALL_PROXY'
alias l='curl "http://172.30.255.42:801/eportal/portal/login?user_account=392432&user_password=12542614" ; echo'
alias v='nvim'
alias iv='nvim ~/.config/nvim/init.vim'
alias devenv='xhost + >> /dev/null;\
    podman start devenv;\
    podman exec -it \
        -e XMODIFIERS=$XMODIFIERS \
        -e QT_IM_MODULE=$QT_IM_MODULE \
        -e GTK_IM_MODULE=$GTK_IM_MODULE \
        -e DISPLAY=$DISPLAY \
        devenv /bin/bash -c \
        "cd /home/devenv/; su devenv;"'
alias u='sudo apt update; sudo apt upgrade -y;'
```
