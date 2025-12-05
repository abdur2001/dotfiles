set positional-arguments

list-recipes:
    just --list
alias default := list-recipes

src_dir := justfile_directory() / "src"
config :=  justfile_directory() / "setup-symlinks" / "config" / "links.yaml"

# setup symlinks
setup-symlinks src_dir=src_dir config=config:
    cd setup-symlinks && poetry run setup_symlinks -- --src-dir "{{ src_dir }}" --config "{{ config }}"

