.PHONY: install zsh _links links oh-my-zsh spde-apps nvim delta fzf just stylua

SHELL := /bin/bash

just:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/.local/bin/just" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/casey/just/releases/download/1.39.0/just-1.39.0-x86_64-unknown-linux-musl.tar.gz; \
	  tar xzvf just-1.39.0-x86_64-unknown-linux-musl.tar.gz; \
	  mv "just" "$${HOME}/.local/bin/just"; \
	  rm -rf "$${tmpdir}"; \
	fi

nvim:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/.local/bin/nvim" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/neovim/neovim-releases/releases/download/v0.11.1/nvim-linux-x86_64.appimage; \
	  chmod +x nvim-linux-x86_64.appimage; \
	  mv "nvim-linux-x86_64.appimage" "$${HOME}/.local/bin/nvim"; \
	  rm -rf "$${tmpdir}"; \
	fi

delta:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/.local/bin/delta" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-musl.tar.gz; \
	  tar xzvf delta-0.18.2-x86_64-unknown-linux-musl.tar.gz; \
	  mv "./delta-0.18.2-x86_64-unknown-linux-musl/delta" "$${HOME}/.local/bin/delta"; \
	  rm -rf "$${tmpdir}"; \
	fi

fzf:
	set -euo pipefail; \
	if [ ! -f "$${HOME}/.local/bin/fzf" ]; then \
	  tmpdir="$$(mktemp -d)"; \
	  cd "$${tmpdir}"; \
	  wget https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-linux_amd64.tar.gz; \
	  tar xzvf fzf-0.59.0-linux_amd64.tar.gz; \
	  mv fzf "$${HOME}/.local/bin/fzf"; \
	  rm -rf "$${tmpdir}"; \
	fi

oh-my-zsh:
	set -euo pipefail; \
	if [ -d "$${HOME}/.oh-my-zsh" ]; then \
	  echo "oh-my-zsh appears to already be installed! Remove the directory if safe to do so and this is not the case."; \
	else \
	  sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	fi

stylua:
	set -euo pipefail; \
	if [ ! -d "${HOME}/.local/bin/stylua" ]; then \
	  if [ ! -d "$${HOME}/tmp" ]; then \
	    mkdir "$${HOME}/tmp"; \
	  fi; \
	  cd "$${HOME}/tmp"; \
	  wget https://github.com/JohnnyMorganz/StyLua/releases/download/v2.1.0/stylua-linux-x86_64-musl.zip; \
	  unzip stylua-linux-x86_64-musl.zip; \
	  mv stylua "$${HOME}/.local/bin/"; \
	fi

# Install prerequisites.
install: oh-my-zsh nvim delta fzf just stylua
	set -euo pipefail; \
	export PATH="$${HOME}/.local"/.local/bin:"$${PATH}"; \
	if poetry --version; then \
	  echo "poetry installed"; \
	else \
	  echo "installing poetry..."; \
	  curl -sSL https://install.python-poetry.org | python3 -; \
	fi; \
	cd ./setup-symlinks; \
	poetry env use /usr/bin/python3; \
	poetry install;

# Install symlinks (no prerequisites).
_links:
	set -euo pipefail; \
	cd ./setup-symlinks; \
	export PATH="$${HOME}/.local"/.local/bin:"$${PATH}"; \
	poetry run setup_symlinks --src-dir ../src --config config/links.yaml; \
	chmod 600 "$${HOME}/.local/.config/spde/context.yaml";

# Install symlinks.
links: install
