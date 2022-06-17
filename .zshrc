# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.dotfiles/shell/zsh/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

# custom scripts

_change_dir() {
  dirtomove=$(ls | fzf)
  cd "$dirtomove"
}

_reverse_search() {
  local selected_command=$(fc -rnl 1 | fzf)
  LBUFFER=$selected_command
}

zle -N _change_dir
bindkey '^h' _change_dir

zle -N _reverse_search
bindkey '^r' _reverse_search

# aliases

alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# find out which distribution we are running on
_distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')

# update alias
case $_distro in
*neon*) alias uos='sudo apt-mark auto $(apt-mark showmanual | grep -E "^linux-([[:alpha:]]+-)+[[:digit:].]+-[^-]+(|-.+)$"); sudo pkcon refresh && sudo pkcon -y update' ;;
*) alias uos='sudo apt-mark auto $(apt-mark showmanual | grep -E "^linux-([[:alpha:]]+-)+[[:digit:].]+-[^-]+(|-.+)$"); sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove' ;;
esac

# set an icon based on the distro
case $_distro in
*kali*) ICON="ﴣ" ;;
*neon*) ICON="" ;;
*arch*) ICON="" ;;
*debian*) ICON="" ;;
*raspbian*) ICON="" ;;
*ubuntu*) ICON="" ;;
*elementary*) ICON="" ;;
*fedora*) ICON="" ;;
*coreos*) ICON="" ;;
*gentoo*) ICON="" ;;
*mageia*) ICON="" ;;
*centos*) ICON="" ;;
*opensuse* | *tumbleweed*) ICON="" ;;
*sabayon*) ICON="" ;;
*slackware*) ICON="" ;;
*linuxmint*) ICON="" ;;
*alpine*) ICON="" ;;
*aosc*) ICON="" ;;
*nixos*) ICON="" ;;
*devuan*) ICON="" ;;
*manjaro*) ICON="" ;;
*rhel*) ICON="" ;;
*) ICON="" ;;
esac

export STARSHIP_DISTRO="$ICON"

function set_win_title() {
  echo -ne "\033]0;$USER@$HOST: $(basename "$PWD")\007"
}
precmd_functions+=(set_win_title)

function free_space() {
  FREE_SPACE="$(df --output=pcent . | sed 1d | awk '{ print (substr($1, 1, length($1)-1)) }')"
  if [[ $FREE_SPACE -gt 95 ]]; then
    export FREE_SPACE_RED="$FREE_SPACE%"
  elif [[ $FREE_SPACE -gt 90 ]]; then
    export FREE_SPACE_YELLOW="$FREE_SPACE%"
  else
    export FREE_SPACE_GREEN="$FREE_SPACE%"
  fi
}
precmd_functions+=(free_space)

# Starship
eval "$(starship init zsh)"
alias shopt='/usr/bin/shopt'
