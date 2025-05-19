return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    log_level = "info",
    auto_session_enable_last_session = true,
    auto_session_create_enabled = true,
    auto_restore_enabled = true, -- Restore sessions automatically
    auto_save_enabled = true, -- Save sessions automatically

    -- Use session-lens for searching saved sessions
    session_lens = {
      load_on_setup = true,
      theme_conf = { border = true },
      previewer = false,
    },
  },
}
