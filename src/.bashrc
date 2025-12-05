# ====================
#    General config
# ====================
#
[[ $- == *i* ]] || return
[[ $(uname -n) == *d ]] || return

export APPS_HOME=/apps/home/${USER}
export WORKSPACE=${APPS_HOME}/workspace
export SPDE_APPS=${WORKSPACE}/spde-apps
export US_POWER=${WORKSPACE}/us-power
export ASDF_CONFIG_FILE=${APPS_HOME}/.asdfrc
export ASDF_DATA_DIR=${APPS_HOME}/.asdf
export ASDF_DIR=${APPS_HOME}/.asdf
export GOOGLE_CLOUD_PROJECT="sqpc-research-dse"
export GOOGLE_APPLICATION_CREDENTIALS="/lxhome/${USER}/.config/gcloud/application_default_credentials.json"
export NOMAD_ADDR="http://nomad.sqpc.sqrpnt.com:4646"
export NOMAD_TOKEN="b51bf419-3a74-9888-1778-72fafadc39e3"
export GITLAB_TRIGGER_TOKEN="glptt-5f87a709a29593695876326bd2b5fd1a2e850f80"

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

export PATH="/opt/third/tmux/3.3/bin:$PATH"

# set the default python breakpoint
export PYTHONBREAKPOINT='ipdb.set_trace'

if [ ! -d "${APPS_HOME}/.asdf" ]; then
  echo "Cloning asdf...";
  git clone https://github.com/asdf-vm/asdf.git ${APPS_HOME}/.asdf --branch v0.18.0;
fi
if [ -f ${APPS_HOME}/.asdf/asdf.sh ]; then
  # Load asdf
  . ${APPS_HOME}/.asdf/asdf.sh
  # Load asdf bash completions
  . ${APPS_HOME}/.asdf/completions/asdf.bash
fi
# Disable asdf nodejs signature check
export NODEJS_CHECK_SIGNATURES=no


# We already know we are running interactively at this point.
if [ -f "${HOME}/bin/zsh/bin/zsh" ]; then
  exec "${HOME}/bin/zsh/bin/zsh"
fi

# Executes on navigation
export PROMPT_COMMAND='($HOME/session_title.sh &)'

for file in \
  "/opt/rh/rh-python36/enable" \
  "/opt/rh/rh-python38/enable" \
  "/opt/rh/devtoolset-9/enable" \
  "/opt/rh/rh-postgresql95/enable" \
  "/opt/third/python/3.10/enable" \
  "/opt/third/python/3.12/enable" \
  "/lxhome/${USER}/.aliases" \
  "/lxhome/${USER}/.functions" \
  "/opt/third/gcc/14.2.0/enable" \
  "${spde_apps_tools_dir}/init-env.sh" \
  "${spde_apps_tools_dir}/de-bash/cloud.sh" \
  "${spde_apps_tools_dir}/de-bash/common.sh" \
  "${spde_apps_tools_dir}/de-bash/gitlab.sh" \
  "${spde_apps_tools_dir}/de-bash/nomad.sh" \
  "${spde_apps_tools_dir}/de-bash/psql.sh" \
  "${spde_apps_tools_dir}/de-bash/verify.sh" \
  "${spde_apps_tools_dir}/de-bash/work.sh" \
  "${spde_apps_tools_dir}/de-bash/k.sh" \
  "${spde_apps_tools_dir}/de-bash/pretty.sh" \
  "${spde_apps_tools_dir}/statenode-cli/statenode.sh" \
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
