. $LOG_MESSAGE_PATH;

todo() {
  local todo_dir="~/lab/tmp/todo/";
  cd "$todo_dir" || { print_message error "Failed to change directory to $todo_dir"; return 1; }

  local today_file="TODO.$(date +%Y%m%d).md"
  local yesterday_file="TODO.$(date -d "yesterday" +%Y%m%d).md"
  
  if [[ -f "$yesterday_file" ]]; then
    grep "[]" "$yesterday_file" > "$today_file"
  else
    local latest_file=$(ls -t TODO.*.md 2>/dev/null | head -n 1)
    if [[ -n "$latest_file" ]]; then
      grep "[]" "$latest_file" > "$today_file"
    else
      print_message info "No TODO files found. Creating an empty TODO file."
      touch "$today_file"
    fi
  fi

  nvim "$today_file"
}

kebab_case() {
    local input_string="$1"
    echo "$input_string" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -d '"'
}

nvim (){
  folder=$(basename "$PWD")
  echo -ne "\033]0;nvim/$folder\007";
  /usr/local/bin/nvim;
}
