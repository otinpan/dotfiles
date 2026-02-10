path+=($HOME/.local/nvim-linux-x86_64/bin)
if (type nvim &> /dev/null);then
    alias vim='nvim'
    alias n='nvim'
    alias nvimconfig="nvim ~/.config/nvim"
    export EDITOR='nvim'
elif (type vim &> /dev/null);then
    export EDITOR='vim'
fi

if (type nvim &>/dev/null)
refresh(){
  echo c
}
