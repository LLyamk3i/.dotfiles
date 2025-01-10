local M = {}

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
  selected_text = string.gsub(selected_text, "\\", "\\\\")
  -- selected_text = string.gsub(selected_text, "'", "\\'")
  selected_text = string.gsub(selected_text, '"', '\\"')
  selected_text = string.gsub(selected_text, "%$", "\\$")

  -- Use CopyQ to copy the selected text
  os.execute("copyq add '" .. selected_text .. "'")
  print("Copied to clipboard: " .. selected_text)
end

function M.log(message)
  -- Get the path to the temporary directory
  local temp_dir = os.getenv "TMPDIR" or os.getenv "TEMP" or "/tmp"
  local log_file = temp_dir .. "/nvim.log"

  -- Open the log file in append mode
  local file = io.open(log_file, "a")
  if file then
    -- Write the message with a timestamp
    file:write(os.date "%Y-%m-%d %H:%M:%S" .. " - " .. message .. "\n")
    -- Close the file
    file:close()
  else
    print "Error: Could not open log file."
  end
end

return M
