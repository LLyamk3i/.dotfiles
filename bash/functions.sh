todo () {
  cd ~/lab/tmp/todos/
  [ ! -f TODO.$(date +%Y%m%d).txt ] && grep "\[\]" TODO.$(date -d "yesterday" +%Y%m%d).txt > TODO.$(date +%Y%m%d).txt
  nvim TODO.$(date +%Y%m%d).txt
}

kebab_case() {
    local input_string="$1"
    echo "$input_string" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -d '"'
}
