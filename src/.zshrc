# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

# Install powerlevel10k using:
plugin_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d  "$plugin_dir" ]; then
    echo "Cloning powerlevel10k theme into:$plugin_dir"
    git clone https://github.com/romkatv/powerlevel10k.git "$plugin_dir"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

zsh_autosuggestion_plugin_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d  "${zsh_autosuggestion_plugin_dir}" ]; then
    echo "Cloning zsh-autosuggestions into:${zsh_autosuggestion_plugin_dir}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_autosuggestion_plugin_dir}"
fi

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git pyenv colored-man-pages colorize pip git-auto-fetch docker pylint z docker-compose asdf zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

function show_unique_added_lines() {
  git show "$1" | grep '^\+[^+]' | gsed 's/\+\s*//' | sort -u | less
}

function remote_dev_files() {
  local current_branch="$(git_current_branch)";
  local origin_name="origin";
  local origin_current_branch="${origin_name}/${current_branch}";
  local git_diff_args=("--name-only" "--relative");

  local origin_cmp_branch;
  if [ $# -eq 0 ]; then
    origin_cmp_branch="${origin_name}/master";
  else
    origin_cmp_branch="${origin_name}/$1";
    shift;
    if [ $# -gt 0 ]; then
      git_diff_args+=("--");
      git_diff_args+="$@";
    fi
  fi

  {
    git diff "${origin_current_branch}" $(git merge-base "${origin_current_branch}" "${origin_cmp_branch}") "${git_diff_args[@]}" \
    && git diff $(git merge-base "${current_branch}" "${origin_cmp_branch}") "${git_diff_args[@]}" ;
  } | sort -u | xargs
}

# drfb wrt master
function drf() {
  git diff origin/$(git_current_branch) -- $(remote_dev_files master "$@")
}

# drf - call like 'branch name' -- args...
function drfb() {
  git diff origin/$(git_current_branch) -- $(remote_dev_files "$@")
}


setopt BASH_REMATCH
setopt KSH_ARRAYS

for file in \
  "${HOME}/.aliases" \
  "${HOME}/.functions" \
; do
  if [ -f "${file}" ]; then
    source "${file}";
  else
    echo "${file} could not be found, skipping!";
  fi
done

unsetopt BASH_REMATCH
unsetopt KSH_ARRAYS

# See https://www.reddit.com/r/vim/comments/9bm3x0/ctrlz_binding/?rdt=44691
# Allow Ctrl-z to toggle between suspend and resume
function Resume {
    fg
    zle push-input
    BUFFER=""
    zle accept-line
}
zle -N Resume
bindkey "^Z" Resume

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
