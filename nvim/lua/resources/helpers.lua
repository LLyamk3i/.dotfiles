local M = {}

-- Function to copy the current file's relative path to CopyQ
function M.copy_relative_path_to_copyq()
  -- Get the current file's absolute path
  local absolute_path = vim.fn.expand "%:p"
  -- Get the current working directory
  local cwd = vim.fn.getcwd()
  -- Convert the absolute path to a relative path
  local relative_path = vim.fn.fnamemodify(absolute_path, ":.")
  -- Use CopyQ to copy the relative path to the clipboard
  vim.fn.system("copyq add " .. vim.fn.shellescape(relative_path))
  -- Notify the user
  vim.notify("Copied relative path to CopyQ: " .. relative_path, vim.log.levels.INFO)
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
