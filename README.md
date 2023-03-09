This my neovim config.

</br>

To use this, you can download files to your customized path or run the following one-line command:

```bash
curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config.sh | sh
```
</br>

To install latest nodejs of coc.nvim in China, you can run the following one-line command, but before running the command I strongly recommand switching to a non-root user firstly:

```bash
curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nodejs-installer.sh | bash
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
    su devenv
```
