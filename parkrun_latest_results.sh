#!/bin/bash
# Результаты последнего забега паркран
# если скрипт запускается без параметров, то читаются результаты паркран Королёв
# если задан параметр командной строки, то он используется в качестве имени забега
# имя паркрана можно посмотреть в адресной строке домашней страницы забега
# например для Вернадского (https://www.parkrun.ru/vernadskogo/) это vernadskogo  
# для Коломенского kolomenskoe, для Измайлово izmailovo и т.д. 

parkrun='korolev'
if [[ -n "$1" ]]; then
	parkrun=$1
fi

result_page='https://www.parkrun.ru/'$parkrun'/results/latestresults/'
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'
last_event=`curl -s -A "$user_agent" $result_page | awk -F"Проведено забегов: " '{print $2}' | awk -F"</div>" '{print $1}'`

echo "Паркран "$parkrun". забег номер "$last_event

# скачиваем содержимое страницы с результатами забега 
echo "обработка" $result_page
page=`curl -s -A "$user_agent" $result_page`

# имя файла для записи последних результатов забега  (korolev_latest_results.html) 
latestresult=$parkrun'_latest_results.html'
echo $page > $latestresult
	
Volunteers=`echo $page | awk -F"благодаря которым состоялся этот забег:" '{print $2}' | awk -F"</p>" '{print $1}'`
vCount=`echo $Volunteers | awk -F"</a>," '{print NF}'`
echo "количество волонтеров:" $vCount 

latest_volunteers=$parkrun'_latest_volunteers.txt'
echo -n > $latest_volunteers
echo "запись файла " $latest_volunteers
for(( i=1; i<=$vCount; ++i ))
do
	Volunteer=`echo $Volunteers | awk -F"</a>," '{print $'"$i"'}'`         
	athleteId=`echo $Volunteer | awk -F"Number=" '{print $2}' | awk -F"'>" '{print $1}'`
	Name=`echo $Volunteer | awk -F">" '{print $2}' | awk -F"<" '{print $1}'`
	echo -e $parkrun "\t" $last_event "\t" "A"$athleteId" "$Name >> $latest_volunteers 
done	

