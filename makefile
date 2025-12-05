.PHONY: install zsh _links links oh-my-zsh spde-apps nvim delta fzf just stylua

SHELL := /bin/bash

just:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/bin/just" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/casey/just/releases/download/1.39.0/just-1.39.0-x86_64-unknown-linux-musl.tar.gz; \
	  tar xzvf just-1.39.0-x86_64-unknown-linux-musl.tar.gz; \
	  mv "just" "$${HOME}/bin/just"; \
	  rm -rf "$${tmpdir}"; \
	fi

nvim:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/bin/nvim" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/neovim/neovim-releases/releases/download/v0.11.1/nvim-linux-x86_64.appimage; \
	  chmod +x nvim-linux-x86_64.appimage; \
	  mv "nvim-linux-x86_64.appimage" "$${HOME}/bin/nvim"; \
	  rm -rf "$${tmpdir}"; \
	fi

delta:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/bin/delta" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-musl.tar.gz; \
	  tar xzvf delta-0.18.2-x86_64-unknown-linux-musl.tar.gz; \
	  mv "./delta-0.18.2-x86_64-unknown-linux-musl/delta" "$${HOME}/bin/delta"; \
	  rm -rf "$${tmpdir}"; \
	fi

fzf:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/bin/fzf" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-linux_amd64.tar.gz; \
	  tar xzvf fzf-0.59.0-linux_amd64.tar.gz; \
	  mv fzf "$${HOME}/bin/fzf"; \
	  rm -rf "$${tmpdir}"; \
	fi

zsh:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/bin/zsh/bin/zsh" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  git clone --depth=1 https://github.com/zsh-users/zsh.git; \
	  cd zsh; \
	  ./Util/preconfig; \
	  mkdir "$${HOME}/bin/zsh"; \
	  ./configure --prefix="$${HOME}/bin/zsh"; \
	  make install; \
	  rm -rf "$${tmpdir}"; \
	fi

oh-my-zsh:
	set -euo pipefail; \
	if [ -d "$${HOME}/.oh-my-zsh" ]; then \
	  echo "oh-my-zsh appears to already be installed! Remove the directory if safe to do so and this is not the case."; \
	else \
	  sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	fi

spde-apps:
	set -euo pipefail; \
	if [ ! -d "/apps/home/${USER}/workspace" ]; then \
	  mkdir -p "/apps/home/${USER}/workspace"; \
	  cd "/apps/home/${USER}/workspace"; \
	  git clone ssh://git@gitlab.sqpc.sqrpnt.com:2222/data/alpha-data/spde-apps.git; \
	fi

stylua:
	set -euo pipefail; \
	if [ ! -d "$${HOME}/bin/stylua" ]; then \
	  if [ ! -d "/apps/home/$${USER}/tmp" ]; then \
	    mkdir "/apps/home/$${USER}/tmp"; \
	  fi; \
	  cd "/apps/home/$${USER}/tmp"; \
	  wget https://github.com/JohnnyMorganz/StyLua/releases/download/v2.1.0/stylua-linux-x86_64-musl.zip; \
	  unzip stylua-linux-x86_64-musl.zip; \
	  mv stylua "$${HOME}/bin/"; \
	fi

# Install prerequisites.
install: zsh oh-my-zsh spde-apps nvim delta fzf just stylua
	set -euo pipefail; \
	export PATH="$${HOME}"/.local/bin:"$${PATH}"; \
	if poetry --version; then \
	  echo "poetry installed"; \
	else \
	  echo "installing poetry..."; \
	  /opt/third/python/3.12/root/bin/pip3 install poetry; \
	fi; \
	cd ./setup-symlinks; \
	poetry env use /opt/third/python/3.12/root/bin/python; \
	poetry install;

# Install symlinks (no prerequisites).
_links:
	set -euo pipefail; \
	cd ./setup-symlinks; \
	export PATH="$${HOME}"/.local/bin:"$${PATH}"; \
	poetry run setup_symlinks --src-dir ../src --config config/links.yaml; \
	chmod 600 "$${HOME}/.config/spde/context.yaml";

# Install symlinks.
links: install
