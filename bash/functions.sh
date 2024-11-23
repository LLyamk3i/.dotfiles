todo () {
  cd ~/lab/tmp/todos/
  [ ! -f TODO.$(date +%Y%m%d).md ] && grep "\[\]" TODO.$(date -d "yesterday" +%Y%m%d).md > TODO.$(date +%Y%m%d).md
  nvim TODO.$(date +%Y%m%d).md
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
