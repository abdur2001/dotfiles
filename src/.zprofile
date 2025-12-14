export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if [ -d "${PYENV_ROOT}" ]; then
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init --path)";
        eval "$(pyenv virtualenv-init -)";
    fi
fi

