export JAVA_HOME=/snap/openjdk/current
export PATH=$PATH:$JAVA_HOME/bin/

if [[ $- == *i* ]]; then
    if [ -f "${HOME}/.bashrc" ]; then
        source "${HOME}/.bashrc"
    fi
fi
