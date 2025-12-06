# ====================
#    General config
# ====================
#
[[ $- == *i* ]] || return
[[ $(uname -n) == *d ]] || return

export ASDF_CONFIG_FILE=${APPS_HOME}/.asdfrc
export ASDF_DATA_DIR=${APPS_HOME}/.asdf
export ASDF_DIR=${APPS_HOME}/.asdf

# Locale settings necessary for Python3
export LC_ALL="en_US.utf8"
export LANG="en_US.utf8"

if [ -f "${HOME}/.cargo/env" ]; then
  . "${HOME}/.cargo/env";
fi

SSH_ENV="${HOME}/.ssh/agent-environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"$SSH_ENV"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" >/dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" >/dev/null
    #ps $SSH_AGENT_PID doesn't work under Cygwin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ >/dev/null || {
       start_agent
    }
else
    start_agent
fi

# ====================
# Bash-specific config
# ====================

# set the default python breakpoint
export PYTHONBREAKPOINT='ipdb.set_trace'

# We already know we are running interactively at this point.
if [ -f "/usr/bin/zsh" ]; then
  exec "/usr/bin/zsh"
fi


for file in \
  "/lxhome/${USER}/.aliases" \
  "/lxhome/${USER}/.functions" \
; do
  if [ -f "${file}" ]; then
    echo "Sourcing ${file}";
    source "${file}";
  else
    echo "${file} could not be found, skipping!";
  fi
done

# fzf bash integration
eval "$(fzf --bash)"
