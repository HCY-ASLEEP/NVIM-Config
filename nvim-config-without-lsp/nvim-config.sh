echo "  vim-plug download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo
echo "  init.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/init.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/nvim-config-without-lsp/init.vim'
echo
echo "  autocomplete.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/autocomplete.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/autocomplete.vim'
echo
echo "  format.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/format.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/format.vim'
echo
echo "  markdown.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/markdown.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/markdown.vim'
echo
echo "  netrw.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/netrw.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/netrw.vim'
echo
echo "  redir.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/redir.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/redir.vim'
echo
echo "  search-folding.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/search-folding.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/search-folding.vim'
echo
echo "  sets-maps.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/sets-maps.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/sets-maps.vim'
echo
echo "  ui.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/ui.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/ui.vim'
echo
echo "  buffer-list.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/redir/buffer-list.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/redir/buffer-list.vim'
echo
echo "  file-search.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/redir/file-search.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/redir/file-search.vim'
echo
echo "  word-search.vim download start"
echo
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.config}"/nvim/vim/redir/word-search.vim --create-dirs https://raw.githubusercontent.com/HCY-ASLEEP/NVIM-Config/main/vim/redir/word-search.vim'
echo

