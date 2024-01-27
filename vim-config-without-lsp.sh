dir_path="~/.config/nvim/"
if [ -d "$dir_path" ]; then
  echo ""
  echo "Directory $dir_path exists"
  echo "----- ABORT -----"
  echo "You can backup $dir_path and remove $dir_path , then try again"
  echo ""
  exit 0
fi
curl -sL https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config-without-lsp/nvim-config.sh | sh
mv ~/.config/nvim/* ~
rm -r ~/.config/nvim/
mv ~/init.vim ~/.vimrc
