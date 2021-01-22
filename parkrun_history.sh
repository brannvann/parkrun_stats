#!/bin/bash
# история забега паркран

# если скрипт запускается без параметров, то считается статистика паркрана Королёв
# если задан параметр командной строки, то он используется в качестве имени забега
# имя паркрана можно посмотреть в адресной строке домашней страницы забега
# например для Вернадского (https://www.parkrun.ru/vernadskogo/) это vernadskogo  
# для Коломенского kolomenskoe, для Измайлово izmailovo и т.д. 

parkrun='korolev'
if [[ -n "$1" ]]; then
	parkrun=$1
fi

history_page='https://www.parkrun.ru/'$parkrun'/results/eventhistory/'
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'
history_src=`curl -s -A "$user_agent" $history_page`

event_table=`echo $history_src | awk -F"<div id=\"primary\">" '{print $2}' | awk -F"<tbody[^>]*?>" '{print $2}' | awk -F"</tbody>" '{print $1}'`
event_count=`echo $event_table | awk -F"<tr[^>]*?><td[^>]*?>" '{print NF}'`

result_file=$parkrun"_history.txt"
echo -n > "$result_file"

for(( i=2; i<=event_count; ++i ))
do
	table_row=`echo $event_table | awk -F"<tr class=\"Results-table-row\" " '{print $'"$i"'}'`

	event_number=`echo $table_row | awk -F'data-parkrun="' '{print $2}' | awk -F'"' '{print $1}'`
	event_date=`echo $table_row | awk -F'data-date="' '{print $2}' | awk -F'"' '{print $1}'`
	event_runners=`echo $table_row | awk -F'data-finishers="' '{print $2}' | awk -F'"' '{print $1}'`
	event_volunteers=`echo $table_row | awk -F'data-volunteers="' '{print $2}' | awk -F'"' '{print $1}'`
	first_man_id=`echo $table_row | awk -F'athleteNumber=' '{print $2}' | awk -F'"' '{print $1}'`
	first_man_name=`echo $table_row | awk -F'athleteNumber=[0-9]+">' '{print $2}' | awk -F'<\/a>' '{print $1}'`
	first_man_time=`echo $table_row | awk -F'<\/a>\(М\) ' '{print $2}' | awk -F'<\/div>' '{print $1}'`

	first_female_id=`echo $table_row | awk -F'athleteNumber=' '{print $3}' | awk -F'"' '{print $1}'`
	first_female_name=`echo $table_row | awk -F'athleteNumber=[0-9]+">' '{print $3}' | awk -F'<\/a>' '{print $1}'`
	first_female_time=`echo $table_row | awk -F'<\/a>\(Ж\) ' '{print $2}' | awk -F'<\/div>' '{print $1}'`

	output_text1=`printf "%s\t%s #%d\t%d\t%d\t" $event_date $parkrun $event_number $event_runners $event_volunteers`
	output_text2=`printf "A%s\t%-30s\t%s\tA%-9s\t%-30s\t%s\n"  $first_man_id "$first_man_name" $first_man_time	$first_female_id "$first_female_name" $first_female_time`
	echo -e "$output_text1""$output_text2"
	echo -e "$output_text1""$output_text2" >> "$result_file"
done
