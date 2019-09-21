#!/bin/bash
# Среднее число участников забега паркран
# если скрипт запускается без параметров, то читаются результаты паркран Королёв
# если задан параметр командной строки, то он используется в качестве имени забега
# имя паркрана можно посмотреть в адресной строке домашней страницы забега
# например для Вернадского (https://www.parkrun.ru/vernadskogo/) это vernadskogo  
# для Коломенского kolomenskoe, для Измайлово izmailovo и т.д. 

parkrun='korolev'
if [[ -n "$1" ]]; then
	parkrun=$1
fi

parkrun_page='https://www.parkrun.ru/'$parkrun'/'
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'
average=`curl -s -A "$user_agent" $parkrun_page | grep "Среднее число бегунов" | awk '{print $6}'  `

echo $parkrun"   "$average

