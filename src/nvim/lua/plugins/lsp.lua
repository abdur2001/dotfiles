return {
  {
    -- `lazy-dev` configures Lua LSP for your Neovim config, runtime and plugins
    -- Used for completion, annotations and signatures or Neovim APIs
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  }
}
