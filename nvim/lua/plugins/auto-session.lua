return {
  "rmagatti/auto-session",
  lazy = false,
  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    log_level = "info",
    auto_session_enable_last_session = true,
    auto_session_create_enabled = true,
    auto_session_root_dir = vim.fn.expand(vim.fn.getcwd() .. "/.nvim/"), -- Set the session directory to .nvim in the current working directory
  },
}
