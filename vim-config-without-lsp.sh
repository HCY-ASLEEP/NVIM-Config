dir_path=$HOME"/.config/nvim/"
if [ -d "$dir_path" ]; then
  echo ""
  echo "Directory $dir_path exists"
  echo "----- ABORT -----"
  echo "You can backup $dir_path and remove $dir_path , then try again"
  echo ""
  unset dir_path
  exit 1
fi
curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config-without-lsp/nvim-config.sh | sh
dir_path=$HOME"/vim/"
if [ -d "$dir_path" ]; then
    rm -r ~/vim/
fi
mv ~/.config/nvim/* ~
rm -r ~/.config/nvim/
mv ~/init.vim ~/.vimrc
