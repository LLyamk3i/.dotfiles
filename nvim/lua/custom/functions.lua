local M = {}

function M.sort_selected_by_length()
  -- Get the current visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]

  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Sort the lines by length
  table.sort(lines, function(a, b) return #a < #b end)

  -- Set the sorted lines back to the buffer
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Function to trim whitespace from both ends of a string
function M.trim(s)
  return s:match("^%s*(.-)%s*$")  -- Match and return the trimmed string
end

-- Function to copy selected text to clipboard using CopyQ
function M.copyq()
  -- Clear the z register
  vim.fn.setreg('z', '')  -- Clear the contents of register z

  -- Yank the selected text to the unnamed register
  vim.cmd('normal! "zy')  -- Yank the selected text into register z

  -- Get the yanked text from register z
  local selected_text = vim.fn.getreg('z')  -- Get the contents of register z
  if selected_text == "" then
    print("No text selected!")
    return
  end

  -- Trim the selected text
  -- selected_text = M.trim(selected_text)

  -- Use CopyQ to copy the selected text
  os.execute('copyq add "' .. selected_text .. '"')
  print("Copied to clipboard: " .. selected_text)
end

return M

