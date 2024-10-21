local M = {}

-- Function to trim whitespace from both ends of a string
function M.trim(s)
  return s:match("^%s*(.-)%s*$")  -- Match and return the trimmed string
end

-- Function to escape special characters for shell command
function M.escape_shell_arg(arg)
  return arg:gsub("([\"'\\])", "\\%1"):gsub("(%s)", "\\ ")  -- Escape quotes and spaces
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
  selected_text = M.trim(selected_text)

  -- Escape special characters
  local selected_text = M.escape_shell_arg(selected_text)

  -- Use CopyQ to copy the selected text
  os.execute('copyq add "' .. selected_text .. '"')
  print("Copied to clipboard: " .. selected_text)
end

return M

