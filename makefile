REPO_URL = https://github.com/neovim/neovim.git
REPO_DIR = neovim
DEPS = ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen

$(REPO_DIR):
	@git clone $(REPO_URL)

lua:
	@wget https://www.lua.org/ftp/lua-5.4.8.tar.gz
	@tar zxpf lua-5.4.8.tar.gz
	@cd lua-5.4.8 && make all test && sudo make install
	@rm lua-5.4.8 -rf
	
lua_rocks: lua
	@wget https://luarocks.org/releases/luarocks-3.12.2.tar.gz
	@tar zxpf luarocks-3.12.2.tar.gz
	@cd luarocks-3.12.2 && ./configure && make && sudo make install
	@rm luarocks-3.12.2 -rf

install_deps:
	@echo "Installing system dependencies..."
	@sudo apt update
	@sudo apt install -y $(DEPS)

build: $(REPO_DIR)
	@echo "Building Neovim from source..."
	@cd $(REPO_DIR) && git checkout stable && make CMAKE_BUILD_TYPE=RelWithDebInfo

install: build
	@echo "Installing Neovim to $(INSTALL_DIR)..."
	@cd $(REPO_DIR) && sudo make install

nvim: lua lua_rocks install_deps $(REPO_DIR) build install

clean:
	@echo "Cleaning up build files..."
	@cd $(REPO_DIR) && make clean
	@rm neovim -rf
