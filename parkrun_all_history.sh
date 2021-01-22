#!/bin/bash
# результаты и статистика волонтеров на прошедших забегах parkrun russia

function ProgressBar {
  _progress=$(((${1}*10000/${2})/100))
	_done=$((_progress*4/10))
	_left=$((40-_done))
	_done=$(printf "%${_done}s")
	_left=$(printf "%${_left}s")
  printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"
}

if [[ ! -f parkruns_russia.txt ]]; then
  ./all_parkruns.sh
fi

_start=1
_stop=$(cat parkruns_russia.txt | wc -l)

history_dir='all_history'

if [[ ! -d "$history_dir" ]]; then
	echo "Making directory" "$history_dir"
	mkdir "$history_dir"
fi
cd "$history_dir"

russia_all_history='_russia_all_history.txt'
echo -n > "$russia_all_history"	

while read parkrun; do
  ProgressBar $_start $_stop
	_start=$((_start + 1))
	event_history=$parkrun"_history.txt"
  ../parkrun_history.sh "$parkrun"
	cat "$event_history" >> "$russia_all_history"
done < ../parkruns_russia.txt
echo ""
