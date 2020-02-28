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

event_table=`echo $history_src | awk -F"<div id=\"primary\">" '{print $2}' | awk -F"<tbody>" '{print $2}' | awk -F"</tbody>" '{print $1}'`
event_count=`echo $event_table | awk -F"<tr><td>" '{print NF}'`

result_file=$parkrun"_history.txt"
echo -n > "$result_file"

for(( i=2; i<=$event_count; ++i ))
do
	table_row=`echo $event_table | awk -F"<tr><td>" '{print $'"$i"'}'`
	
	event_number=`echo $table_row | awk -F'<|>' '{print $3}'`
	event_date=`echo $table_row | awk -F'<|>' '{print $11}' | awk -F'/' '{print $3$2$1}'`
	event_runners=`echo $table_row | awk -F'<|>' '{print $17}'`
	event_volunteers=`echo $table_row | awk -F'<|>' '{print $21}'`
	first_man_id=`echo $table_row | awk -F'<|>' '{print $30}' | awk -F'\"|=' '{print $4}'`
	first_man_name=`echo $table_row | awk -F'<|>' '{print $31}'`
	first_man_time=`echo $table_row | awk -F'<|>' '{print $37}'`
	
	first_female_id=`echo $table_row | awk -F'<|>' '{print $46}' | awk -F'\"|=' '{print $4}'`
	first_female_name=`echo $table_row | awk -F'<|>' '{print $47}'`
	first_female_time=`echo $table_row | awk -F'<|>' '{print $53}'`
	
	output_text=$event_date"\t"$parkrun"\t"$event_number"\t"$event_runners"\t"$event_volunteers"\t"
	output_text=$output_text"A"$first_man_id"\t"$first_man_name"\t"$first_man_time"\t"
	output_text=$output_text"A"$first_female_id"\t"$first_female_name"\t"$first_female_time
	echo -e $output_text
	echo -e $output_text >> "$result_file"
done
