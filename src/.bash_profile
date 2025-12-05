export spde_apps_tools_dir="/apps/home/${USER}/workspace/spde-apps/_tools"
export PATH="/lxhome/${USER}/.local/bin:${HOME}/bin:${spde_apps_tools_dir}/de-bash:$PATH"

if [[ $- == *i* ]]; then
    if [ -f "${HOME}/.bashrc" ]; then
        source "${HOME}/.bashrc"
    fi
fi
