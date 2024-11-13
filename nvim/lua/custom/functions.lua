local M = {}

function M.sort_selected_by_length()
  -- Get the current visual selection
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Sort the lines by length
  table.sort(lines, function(a, b)
    return #a < #b
  end)

  -- Set the sorted lines back to the buffer
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Function to copy selected text to clipboard using CopyQ
function M.copyq()
  -- Clear the contents of register z
  vim.fn.setreg("z", "")

  -- Yank the selected text to the z register
  vim.cmd 'normal! "zy'

  -- Get the yanked text from register z
  local selected_text = vim.fn.getreg "z"
  if selected_text == "" then
    print "No text selected!"
    return
  end

  -- Escape single and double quotes in the selected text
  selected_text = string.gsub(selected_text, "'", "\\'")
  selected_text = string.gsub(selected_text, '"', '\\"')
  selected_text = string.gsub(selected_text, '%$', '\\$')

  -- Use CopyQ to copy the selected text
  os.execute('copyq add "' .. selected_text .. '"')
  print("Copied to clipboard: " .. selected_text)
end

return M
