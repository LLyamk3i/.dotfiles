todo ()
{
  cd ~/lab/tmp/todos/
  [ ! -f TODO.$(date +%Y%m%d).txt ] && grep "\[\]" TODO.$(date -d "yesterday" +%Y%m%d).txt > TODO.$(date +%Y%m%d).txt
  nvim TODO.$(date +%Y%m%d).txt
}
