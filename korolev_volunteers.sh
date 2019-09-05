#!/bin/bash
# статистика волонетров на забегах паркран Королев

parkrun='korolev'
total=100
declare -A countMap


result_page='https://www.parkrun.ru/'$parkrun'/results/weeklyresults/?runSeqNumber='
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'
totalresult='korolev_results.html'


for(( event_index=1; event_index<=$total; event_index++ ))
do
	# скачиваем содержимое страницы с результатами забега 
	page_url=$result_page$event_index
	echo "обработка" $page_url
	page=`curl -s -A "$user_agent" $page_url`

	# сохранение в файл ( на всякий случай )
	filename="result"$event_index
	echo $page > $filename
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
		echo $key
		
		value=${countMap[$key]}
		value=$(expr $value + 1)
		countMap[$key]=$value
	done	
	sleep 1
done

echo "================== Волонтеры забега =================="
for K in "${!countMap[@]}"; do echo $K ${countMap[$K]}; done | sort -rn -k4
 
