#!/bin/bash
echo "Сбор статистики о волонтерах на забегах паркран"

# если скрипт запускается без параметров, то считается статистика паркрана Королёв
# если задан параметр командной строки, то он используется в качестве имени забега
# имя паркрана можно посмотреть в адресной строке домашней страницы забега
# например для Вернадского (https://www.parkrun.ru/vernadskogo/) это vernadskogo  
# для Коломенского kolomenskoe, для Измайлово izmailovo и т.д. 

parkrun='korolev'
if [[ -n "$1" ]]; then
	parkrun=$1
fi

function ProgressBar {
  _progress=$(((${1}*10000/${2})/100))
	_done=$((_progress*4/10))
	_left=$((40-_done))
	_done=$(printf "%${_done}s")
	_left=$(printf "%${_left}s")
  printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"
}

declare -A countMap

result_page='https://www.parkrun.ru/'$parkrun'/results/weeklyresults/?runSeqNumber='
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'
total=$(curl -s -A "$user_agent" $result_page |
        awk -F'Мероприятий: <span class="num">' '{print $2}' |
        awk -F'</span>' '{print $1}' |
        tr -d '\n')

echo "Паркран "$parkrun". Всего забегов: "$total

# сюда сохраняются все страницы с результатами забега  (korolev_all_results.html) 
#totalresult=$parkrun'_all_results.html'
#echo -n > $totalresult

# подробная статистика волонтеров по забегу хранится в файлах:
full_stat=$parkrun'_full_stat.txt'
volunteers_file='volunteers_'$parkrun'.txt'
# ------------------------------------------------------------

if [[ -f $full_stat && -f $volunteers_file ]]; then
  # если файлы есть, статистика будет дописана и обновлена
  start_index=$(tail -1 < $full_stat | cut -f2)
  ((++start_index))
  while read line; do
    key=$(echo "$line" | awk -F' [1-9]' '{print $1}')
    value=$(echo "$line" | awk '{print $NF}')
    countMap[$key]=$value
  done < $volunteers_file
else
  # если файлов нет, вся статистика будет скачана заново
  start_index=1
  echo -n > $full_stat
  echo -n > $volunteers_file
fi

for(( event_index=start_index; event_index<=total; event_index++ ))
do
  ProgressBar $event_index $total
	# скачиваем содержимое страницы с результатами забега 
	page_url=$result_page$event_index
	page=$(curl -s -A "$user_agent" $page_url)

	# сохранение результатов забега в файл ( на всякий случай )
  #	echo $page >> $totalresult
	
	Volunteers=$(echo $page | awk -F"Спасибо нашим волонтёрам!</h3>" '{print $2}' | awk -F"</h3>" '{print $1}')
	vCount=$(echo $Volunteers | awk -F"</a>," '{print NF}')
	for(( i=1; i<=vCount; ++i ))
	do
		Volunteer=$(echo $Volunteers | awk -F"</a>" '{print $'"$i"'}')
		athleteId=$(echo $Volunteer | awk -F"Number=" '{print $2}' | awk -F"'>" '{print $1}')
		Name=$(echo $Volunteer | awk -F"'>" '{print $2}')
		key="A"$athleteId" "$Name
		echo -e $parkrun"\t"$event_index"\t"$key >> $full_stat

		value=${countMap[$key]}
		countMap[$key]=$((++value))
	done	
	sleep 0.2
done
echo ""

# вывод списка волонтеров с сортировкой по количеству забегов
echo "===================== Волонтеры забега "$parkrun" ========================"
for K in "${!countMap[@]}"; do echo $K ${countMap[$K]}; done | sort -rn -k4

# вывод списка волонтеров в файл
for K in "${!countMap[@]}"; do echo $K ${countMap[$K]}; done | sort -rn -k4 >> $volunteers_file
