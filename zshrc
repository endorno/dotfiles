#! /usr/bin/env zsh -x
# -*- coding: utf-8 -*-

###############
# common
###############
function exists {
  if which "$1" 1>/dev/null 2>&1; then return 0; else return 1; fi
}

function add_path {
  if [ -d $1 ]; then
    export PATH="${1}:${PATH}"
  fi
}


###############
# environment
###############
#path="${path} /usr/local/bin /bin /sbin /usr/bin /usr/sbin"
add_path "/bin"
add_path "/sbin"
add_path "/usr/bin"
add_path "/usr/sbin"
add_path "/usr/local/bin"
add_path "${HOME}/.dotfiles/bin"

if exists lv; then
  export PAGER=lv
elif exists less; then
  export PAGER=less
fi

export EDITOR=emacs

# C-wで単語の一部と見なす記号
export WORDCHARS='*?_-.[]~&;!#$%^(){}<>'


export LANG=ja_JP.UTF-8
unset LC_ALL
export LC_MESSAGES=C
export SHELL=`which zsh`


add_path "$HOME/bin"
add_path "$HOME/dotfiles/bin"

case "$TERM" in
  xterm*)
  # determine best terminal
  if [ -f /usr/share/terminfo/x/xterm-256color ]; then
    export TERM=xterm-256color
  elif [ -f /usr/share/terminfo/x/xterm-debian ]; then
    export TERM=xterm-debian
  elif [ -f /usr/share/terminfo/x/xterm-color ]; then
    export TERM=xterm-color
  else
    export TERM=xterm
  fi
  ;;
esac

setopt completealiases
case $(uname) in
'Linux')
  alias ls='ls --color=auto -Fh'
  alias l='ls --color=auto -FAlh'
  ;;
'FreeBSD'|'Darwin')
  alias ls='ls -GFh'
  alias l='ls -GFAlh'
  #export LSCOLORS='ExfxcxdxBxegedabagacad'
  export LSCOLORS=gxfxcxdxbxegedabagacad
  ;;
esac
export LV='-Ou8 -c'

alias mv='mv -i'

if exists trash; then
  alias rm='trash'
else
  alias rm='rm -i'
fi


alias quit='exit'
alias ':q'='exit'
alias w3m='w3m -O ja_JP.UTF-8'

alias -g G="| grep "
alias -g XG="| xargs grep "
alias -g CP="| pbcopy"

alias gd='git diff'
alias gdf='git diff --cached'
alias g='git status'
alias gl='git log --oneline'
alias ga='git add'
alias gap='git add -p'
alias gci='git commit -m'

# ----------------------------------------
# history
HISTFILE=~/.zsh_history
HISTSIZE=300000
SAVEHIST=300000
setopt appendhistory
setopt histignorealldups
setopt histnofunctions
setopt histnostore
setopt histreduceblanks
setopt histignorespace # do not add a command line with leading space to the history
setopt share_history

# ----------------------------------------
# zsh
setopt noclobber # 存在するファイルにリダイレクトしない
setopt autocd
setopt autopushd
setopt pushdignoredups
setopt pushd_minus # swap '-' and '+' in the context of pushd
setopt ignoreeof # C-Dでログアウトしない
setopt print_eightbit # multibyte characters
setopt noflowcontrol # no C-S C-Q

###############
# zsh environment
###############
if [ -d "/usr/local/share/zsh-completions" ]; then
  fpath=("/usr/local/share/zsh-completions" $fpath)
fi

autoload -U is-at-least
# colors
autoload -U colors
colors

#keybinds
bindkey -e #emacs風キーバインド
bindkey '^[[1~' beginning-of-line # Home
bindkey '^[[4~' end-of-line # End
bindkey '^T' kill-word
bindkey '^U' backward-kill-line
bindkey '^[[3~' delete-char-or-list # Del
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^[[Z' reverse-menu-complete # Shift+TAB
bindkey '5C' forward-word
bindkey '5D' backward-word


# ----------------------------------------
# insert '(*)' into the head of window title while a command is running
# in job: "(*) path [name@host]"
# finish: "path [name@host]"

case "$TERM" in
  kterm*|xterm*)
    function precmd_title {
      # called in precmd
      print -Pn "\e]0;%m\a"
      print -Pn "\e]2;%~ [%n@%m]\a"
    }
    function preexec {
      print -Pn "\e]0;* %m\a"
      print -Pn "\e]2;(*)%~ [%n@%m]\a"
    }
  ;;
  screen)
    function precmd_title {
      # called in precmd
      print -Pn "\e]0;%m\a"
      print -Pn "\e]2;%~ [%n@%m]\a"
    }
    function preexec {
	1="$1 " #deprecated.
	echo -ne "\ek${${(s: :)1}[1]}\e\\"
    }
    ;;
  *)
    function precmd_title {
    }
  ;;
esac

# ----------------------------------------
# prompt

# git
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '[%b]'
zstyle ':vcs_info:*' actionformats '[%b|%a]'


if [ $TERM = "cygwin" ]; then
  # for Cygwin (ps 1.11)
  function joblist { ps|awk '/^S/{print gensub(/^.*\/(.*?)$/,"\\1", "", $9);}'|sed ':a;$!N;$!b a;;s/\n/,/g' }
  function jobnum { ps|awk '/^S/{print}'|wc -l}
  function ipaddrs { ipconfig | grep 'IP Address' | sed 's/\. //g;s/.*: //g' | grep -v 127.0.0.1 | sed ':a;$!N;$!b a;;s/\n/, /g' }
elif [ $TERM = "xterm" ]; then
  # for mac xterm
function joblist { ps -o stat,command,tty|grep $(basename $(tty))| awk '/^T/{print $2;}'|gsed -e ':a;$!N;$!ba;s/\n/,/g'}

function jobnum { ps -o stat,tty|grep $(basename $(tty))|awk '/^T/&&NR!=1{print}'|wc -l|gsed -e 's/[ ]\+//'}

#  function joblist { ps -o stat,command| awk '/^T/{print $2;}'|gsed -e ':a;$!N;$!ba;s/\n/,/g'}
#  function jobnum { ps -o stat|awk '/^T/&&NR!=1{print}'|wc -l|gsed -e 's/[ ]\+//'}
else
  # for Linux (procps 3.2.6)
  function joblist { ps -l|awk '/^..T/&&NR!=1{print $14}'|sed ':a;$!N;$!b a;;s/\n/,/g' }
  function jobnum { ps -l|awk '/^..T/&&NR!=1{print}'|wc -l}
  function ipaddrs { /sbin/ifconfig | awk '/^ *inet addr:/{print $2}' | cut -d: -f2 | grep -v 127.0.0.1 | sed ':a;$!N;$!b a;;s/\n/, /g' }
fi
function precmd {
  local jn="$(jobnum)"
  if [[ "$jn" -gt 0 ]]; then
    prompt "[$jn]"`joblist`
  else
    prompt ''
  fi
  precmd_title
  # for git
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}

# control sequences for zsh prompt: n lines down, then n lines up
zsh_prompt_color='cyan'
function prompt {
  if [ $UID -eq 0 ]; then

    if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ];then
	local C_USERHOST="%{$bg[white]$fg[red]%}"
	local C_PROMPT="%{$fg[red]%}"
    else
	local C_USERHOST="%{$bg[white]$fg[magenta]%}"
	local C_PROMPT="%{$fg[magenta]%}"
    fi
  else

    if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ];then
	local C_USERHOST="%{$bg[white]$fg[blue]%}"
	local C_PROMPT="%{$fg[white]%}"
    else
	#local C_USERHOST="%{$bg[black]$fg[$zsh_prompt_color]%}"
	local C_USERHOST="%{$bg[black]$fg[cyan]%}"
	#local C_PROMPT="%{$fg[$zsh_prompt_color]%}"
	local C_PROMPT="%{$fg[cyan]%}"
    fi
  fi
  local C_PRE="%{$reset_color%}%{$fg[$zsh_prompt_color]%}"
  local C_CMD="%{$reset_color%}%{$fg[white]%}"
  local C_RIGHT="%{$bg[black]%}%{$fg[white]%}"
  local C_DEFAULT="%{$reset_color%}"
  PROMPT=$C_USERHOST"%S[%n@%m] %~ %s$C_PRE "$1"
"$C_PROMPT"%# "$C_CMD

  RPROMPT="%S"$C_RIGHT"%1(v|%F{green}%1v%f|) ""%* %s"$C_CMD
  echo -n -e "\n\n\n\033[3A"
}
prompt ""
POSTEDIT=`echotc se`
setopt prompt_subst # use colors in prompt
unsetopt promptcr


###############
# file system
###############
#complement when move to upper directory
#autoload -Uz manydots-magic
#manydots-magic

function cd {
  if ! builtin cd 2>/dev/null $@; then
    echo "$fg[yellow]cannot cd: $@$reset_color"
    return
  fi
  if [ "$?" -eq 0 ]; then
    lscdmax=40
    nfiles=$(/bin/ls|wc -l)
    if [ $nfiles -eq 0 ]; then
      if [ "$(/bin/ls -A|wc -l)" -eq 0 ]; then
        echo "$fg[yellow]no files in: $(pwd)$reset_color"
      else
        echo "$fg[yellow]only hidden files in: $(pwd)$reset_color"
        ls -A
      fi
    elif [ $lscdmax -ge $nfiles ]; then
      ls
    else
      echo "$fg[yellow]$nfiles files in: $(pwd)$reset_color"
    fi
  fi
}
#^を押したら上位のディレクトリに動けるように
function cdup() {
   echo
   cd ..
   zle reset-prompt
}
zle -N cdup
bindkey '^\^' cdup

#F5を押すとdatetime用変数を挿入する
function insert_datetime {
  LBUFFER=$LBUFFER'$(date +%Y%m%d-%H%M%S)'
}
function insert_date {
  LBUFFER=$LBUFFER'$(date +%Y%m%d)'
}
zle -N insert_date
zle -N insert_datetime
bindkey '^[[15~' insert_date
bindkey '^[[15;2~' insert_datetime

if [ $((${ZSH_VERSION%.*}>=4.3)) -eq 1 ]; then

  function cdup {
    echo
    cd ..
    echo
    zle reset-prompt
  }
  zle -N cdup
  bindkey '^\^' cdup  # directory up on Ctrl-^


  function cdback {
    if [ "$(printf '%d' "$BUFFER")" = "$BUFFER" ]; then
      # back N level (reset)
      echo
      builtin cd +$BUFFER
      echo
      BUFFER=''
      zle reset-prompt
    else
      # back 1 level (inline)
      echo
      builtin cd -
      echo
      zle reset-prompt
    fi
  }
  zle -N cdback
  bindkey '^O' cdback  # directory back on Ctrl-O

  # ls on single Enter
  if exists /usr/bin/test; then TESTPATH=/usr/bin/test
  else TESTPATH=/bin/test; fi
  function lsoraccept {
    # BUG: use /usr/bin/test rather than builtin [ .
    # calling [ in $CONTEXT = 'cont' will cause segv to zsh 4.3.4
    if $TESTPATH -z "$BUFFER"; then
      echo
      if $TESTPATH $(/bin/ls|wc -l) -eq 0; then
        ls -AF
      else
        ls
      fi
      echo
    else
      zle accept-line
    fi
    # call reset-prompt outside the if-else-fi statement (to prepend showing 'for else>' in PS2)
    zle reset-prompt
  }
  zle -N lsoraccept
  bindkey '^M' lsoraccept   # ls on single Enter

  # resume suspended job
  function zlewidget-fg {
    if [ -z "$(jobs)" ]; then
      return
    fi
    if [ "$(printf '%d' "$BUFFER")" = "$BUFFER" ]; then
      # fg %N
      echo ''
      builtin fg %$BUFFER
      BUFFER=''
      zle reset-prompt
    else
      # fg
      echo ''
      builtin fg
      zle reset-prompt
    fi
  }
  zle -N zlewidget-fg
  bindkey '^Z' zlewidget-fg   # resume suspended job
fi

#ディレクトリ移動＆補完
case $(uname) in
  'FreeBSD'|'Darwin')
    if [[ -s `brew --prefix`/etc/autojump.sh ]];then
     . `brew --prefix`/etc/autojump.sh
    fi
  ;;
  linux*)
  #TODO install autojump for linux
  ;;
esac

autoload -U compinit; compinit -u

export LISTMAX=20
# ls, colors in completion
#export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
autoload colors
colors

# LS_COLORSを設定しておく
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*' menu select=2 # C-f C-b

# match upper case from lower case, search after -_./
# dir => Dir, _t => some_tmp, long.c => longfilename.c
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[-_./]=** r:|=*'

setopt nolistbeep # 曖昧補完でビープしない
setopt no_beep # 補完に失敗してもビープしない
setopt autolist # 補完時にリスト表示
#setopt listpacked # compact list on completion # 不安定?
setopt listtypes
unsetopt menucomplete # 最初から候補を循環する
setopt automenu # 共通部分を補完しそれ以外を循環する準備
setopt extendedglob # 展開で^とか使う
setopt numericglobsort # 数字展開は数値順
#setopt magicequalsubst # completion after '=' # 不安定?

setopt autoparamkeys # 補完後の:,)を削除
fignore=(.o .swp lost+found) # 補完で無視する


#lessに色をつける
which src-hilite-lesspipe.sh 1>/dev/null 2>&1 && export LESS='-R' && export LESSOPEN="| $(which "src-hilite-lesspipe.sh")  %s"

###############
# application
###############
# for Mac OS
if exists gsed; then
  alias sed='gsed'
fi

###############
# utility function
# これらの関数自体を便利関数として使う
###############

#
# measure time.
# usage:
# $ Tic; heavy; Toc
function Tic {
  export LAST_TIC_TIME="$(date +%s)"
  export LAST_TIC_DATE="$(date +%Y/%m/%d\ %H:%M:%S)"
}

function Toc {
  CURRENT_TIME="$(date +%s)"
  CURRENT_DATE="$(date +%Y/%m/%d\ %H:%M:%S)"
  if [ x"$LAST_TIC_TIME" != "x" -a x"$LAST_TIC_DATE" != "x" ]; then
    LAST_TIC_TIME=$LAST_TIC_TIME
    LAST_TIC_DATE=$LAST_TIC_DATE
  else
    echo "Error. run Tic first"
    return
  fi
  DIFF=$(($CURRENT_TIME-$LAST_TIC_TIME))
  SEC=$(($DIFF % 60))
  MIN=$(($DIFF / 60 % 60))
  HOUR=$(($DIFF / 3600))
  echo "elapsed time = $(printf "%02d:%02d:%02d" $HOUR $MIN $SEC)   [$LAST_TIC_DATE] => [$CURRENT_DATE]"
}

function psg {
  # ps aux | grep ... but do not include ps nor grep
  HEAD=$(ps aux | head -n 1) # header
  COMMANDPOS=$(echo $HEAD | sed -r 's@COMMAND$@@' | wc -m) # where 'COMMAND' begins
  COMMANDPOS=$(($COMMANDPOS-1))
  ps aux | while read LINE; do
    echo $LINE | grep -v -E "^.{${COMMANDPOS}}"'(ps aux|grep)' >/dev/null # not ps|grep
    if [ "$?" -ne 0 ]; then continue; fi
    echo $LINE | grep $*
  done
}

###############
# その他
###############

#include local setting file
test -r ~/.zsh/.zshrc.local && source ~/.zsh/.zshrc.local
test -r ~/.zsh/.zshrc.secret && source ~/.zsh/.zshrc.secret

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"




