echo "  vim-plug download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo
echo "  init.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/init.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/init.vim'
echo
echo "  lsp.lua download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/lsp.lua --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/lsp.lua'
echo
echo "  markdown.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/markdown.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/markdown.vim'
echo
