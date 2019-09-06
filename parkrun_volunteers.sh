#!/bin/bash
# статистика волонетров на забегах паркран

# если скрипт запускается без параметров, то считается статистика паркрана Королёв
# если задан параметр командной строки, то он используется в качестве имени забега
# имя паркрана можно посмотреть в адресной строке домашней страницы забега
# например для Вернадского (https://www.parkrun.ru/vernadskogo/) это vernadskogo  
# для Коломенского kolomenskoe, для Измайлово izmailovo и т.д. 

parkrun='korolev'
if [[ -n "$1" ]]; then
	parkrun=$1
fi

declare -A countMap

result_page='https://www.parkrun.ru/'$parkrun'/results/weeklyresults/?runSeqNumber='
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'
total=`curl -s -A "$user_agent" $result_page | awk -F"Проведено забегов: " '{print $2}' | awk -F"</div>" '{print $1}'`

echo "Паркран "$parkrun". Всего забегов: "$total

# сюда сохраняются все страницы с результатами забега  (korolev_all_results.html) 
totalresult=$parkrun'_all_results.html'
echo -n > $totalresult

# подробная статистика волонетров по забегу
full_stat=$parkrun'_full_stat.txt'
echo -n > $full_stat

for(( event_index=1; event_index<=$total; event_index++ ))
do
	# скачиваем содержимое страницы с результатами забега 
	page_url=$result_page$event_index
	echo "обработка" $page_url
	page=`curl -s -A "$user_agent" $page_url`

	# сохранение результатов забега в файл ( на всякий случай )
	echo $page >> $totalresult
	
	Volunteers=`echo $page | awk -F"благодаря которым состоялся этот забег:" '{print $2}' | awk -F"</p>" '{print $1}'`
	vCount=`echo $Volunteers | awk -F"</a>," '{print NF}'`
	echo "забег №" $event_index "количество волонтеров:" $vCount
	for(( i=1; i<=$vCount; ++i ))
	do
		Volunteer=`echo $Volunteers | awk -F"</a>," '{print $'"$i"'}'`         
		athleteId=`echo $Volunteer | awk -F"Number=" '{print $2}' | awk -F"'>" '{print $1}'`
		Name=`echo $Volunteer | awk -F">" '{print $2}' | awk -F"<" '{print $1}'`
		key="A"$athleteId" "$Name
		echo -e $parkrun "\t" $event_index "\t" $key >> $full_stat 
		
		value=${countMap[$key]}
		value=$(expr $value + 1)
		countMap[$key]=$value
	done	
	sleep 1
done

#вывод списка волонтеров с сортировкой по количеству забегов
echo "================== Волонтеры забега "$parkrun" =================="
for K in "${!countMap[@]}"; do echo $K ${countMap[$K]}; done | sort -rn -k4

#вывод списка волонтеров в файл
volunteers_file='volunteers_'$parkrun'.txt'
for K in "${!countMap[@]}"; do echo $K ${countMap[$K]}; done | sort -rn -k4 >> $volunteers_file
