#!/bin/bash
# статистика на забегах паркран

# если скрипт запускается без параметров, то считается статистика паркрана Королёв
# если задан параметр командной строки, то он используется в качестве имени забега
# имя паркрана можно посмотреть в адресной строке домашней страницы забега
# например для Вернадского (https://www.parkrun.ru/vernadskogo/) это vernadskogo  
# для Коломенского kolomenskoe, для Измайлово izmailovo и т.д. 

history_tmp='history_src_tmp'
event_tmp='event_src_tmp'

parkrun='korolev'
if [[ -n "$1" ]]; then
	parkrun=$1
fi

history_page='https://www.parkrun.ru/'$parkrun'/results/eventhistory/'
result_page='https://www.parkrun.ru/'$parkrun'/results/weeklyresults/?runSeqNumber='
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'

history_src=`curl -s -A "$user_agent" $history_page`
sleep 1
event_src=`curl -s -A "$user_agent" $result_page`

echo $history_src > $history_tmp
echo $event_src > $event_tmp

#exit 0
#event_src=`cat $event_tmp`
#history_src=`cat $history_tmp`

futer=`echo $history_src | awk -F"<div id=\"FooterStats\">" '{print $2}' | awk -F"<div class=\"column socialicons\">" '{print $1}'`
total_events=`echo $futer | awk -F"<div class=\"column\">" '{print $2}' | awk -F": " '{print $2}' | awk -F"</div>" '{print $1}'`
total_runners=`echo $futer | awk -F"<div class=\"column\">" '{print $3}' | awk -F": " '{print $2}' | awk -F"</div>" '{print $1}'`
echo "Паркран "$parkrun". Всего забегов: "$total_events" Всего бегунов: "$total_runners

event_table=`echo $history_src | awk -F"<div id=\"primary\">" '{print $2}' | awk -F"<tbody>" '{print $2}' | awk -F"</tbody>" '{print $1}'`
event_count=`echo $event_table | awk -F"<tr><td>" '{print NF}'`
echo "Забегов в таблице истории "$event_count

declare -A event2date
declare -A event2runners
declare -A event2runners

for(( i=2; i<=$event_count; ++i ))
do
	table_row=`echo $event_table | awk -F"<tr><td>" '{print $'"$i"'}'`
	event_number=`echo $table_row | awk -F"</a>" '{print $1}' | awk -F">" '{print $2}'`
	event_date=`echo $table_row | awk -F"</a>" '{print $2}' | awk -F">" '{print $4}' | awk -F"/" '{print $3$2$1}'`
	event_runners=`echo $table_row | awk -F"</a>" '{print $3}' | awk -F"<td>" '{print $2}' | awk -F"</td>" '{print $1}'`
	event_volunteers=`echo $table_row | awk -F"</a>" '{print $3}' | awk -F"<td>" '{print $3}' | awk -F"</td>" '{print $1}'`
	
	echo $parkrun" "$event_number" "$event_date" "$event_runners" "$event_volunteers
	
	event2date[$event_number]=$event_date
	event2runners[$event_number]=$event_runners
	event_volunteers[$event_number]=$event_volunteers
done

result_file=$parkrun"_resuls.txt"
volunteer_file=$parkrun"_volunteers.txt"

#for(( event_index=$total_events-3; event_index<=$total_events; event_index++ ))
for(( event_index=1; event_index<=$total_events; event_index++ ))
do
	eventdate=${event2date[$event_index]}
	if grep -q $eventdate $result_file; 
	then
		echo $parkrun" "$event_index" уже обработан" 
		continue
	fi

	page_url=$result_page$event_index
	echo "обработка " $page_url
	event_src=`curl -s -A "$user_agent" $page_url`

	eventrunners=${event2runners[$event_index]}
	#echo $parkrun" "$event_index" "$eventdate" "$eventrunners" "$eventvolunteers
	for(( runner=1;runner<=$eventrunners; runner++))
	do
		runner_tag='<td class="Results-table-td Results-table-td--position">'$runner
		#echo $runner_tag
		runner_raw=`echo $event_src | awk -F"$runner_tag" '{print $2}' | awk -F"</tr>" '{print $1}' `
		runner_id=`echo $runner_raw | awk -F"?athleteNumber=" '{print $2}' | awk -F"\"" '{print $1}'`
		if [ -n "$runner_id" ]
		then
			runner_name=`echo $runner_raw | awk -F"target=\"_top\">" '{print $2}' | awk -F"</a>" '{print $1}'`
			runner_time=`echo $runner_raw | awk -F"Results-table-td--time" '{print $2}' | awk -F">" '{print $3}' | awk -F"<" '{print $1}'`
			gender=`echo $runner_raw | awk -F"gender Results-table-td--" '{print $2}' | awk -F"\"" '{print $1}'`
			gender_pos=`echo $runner_raw | awk -F"<span class=\"Results-table--genderCount\"" '{print $1}' | awk -F">" '{print $NF}'`
			age_group=`echo $runner_raw | awk -F"ageCat=" '{print $2}' | awk -F"<" '{print $1}' | awk -F">" '{print $2}'`
			age_grade=`echo $runner_raw | awk -F"ageCat=" '{print $2}' | awk -F">" '{print $5}' | awk -F"<" '{print $1}'`
			record=`echo $runner_raw | awk -F"<span class=\"Results-table--normal\">ЛР</span> " '{print $2}' | awk -F"<" '{print $1}'`
			if [ -z "$record" ]
			then
				record=`echo $runner_raw | grep "Первый забег!</span>"`
				if [ -n "$record" ]
				then
					record="Первый забег!"
				else 
					record=`echo $runner_raw | grep "Новый ЛР!</span>"`
					if [ -n "$record" ]
					then
						record="Новый ЛР!"
					fi
				fi
			fi
			runs_count=`echo $runner_raw | awk -F"<span class=\"Results-tablet" '{print $1}' | awk -F">" '{print $NF}' | awk -F" " '{print $1}'`
			
			output_text=$eventdate"\t"$parkrun"\t"$event_index
			output_text=$output_text"\t"$runner"\tA"$runner_id"\t"$runner_name"\t"$runner_time"\t"$gender"\t"$gender_pos
			output_text=$output_text"\t"$age_group"\t"$age_grade"\t"$record"\t"$runs_count
			echo -e $output_text
			echo -e $output_text >> "$result_file"
		else
			echo -e $eventdate"\t"$parkrun"\t"$event_index"\t"$runner"\tНЕИЗВЕСТНЫЙ"
			echo -e $eventdate"\t"$parkrun"\t"$event_index"\t"$runner"\tНЕИЗВЕСТНЫЙ" >> "$result_file"
		fi
		
	done 
	
	volunteer_block=`echo $event_src | awk -F"../../volunteer" '{ print $1}' | awk -F"</h3>" '{print $NF}' | awk -F":" '{print $2}'`
	#echo $volunteer_block
	eventvolunteers=${event_volunteers[$event_index]}
	for(( v=1; v<=$eventvolunteers; v++ ))
	do
		Volunteer=`echo $volunteer_block | awk -F"</a>," '{print $'"$v"'}'`         
		athleteId=`echo $Volunteer | awk -F"Number=" '{print $2}' | awk -F"'>" '{print $1}'`
		Name=`echo $Volunteer | awk -F">" '{print $2}' | awk -F"<" '{print $1}'`
		echo -e $eventdate"\t"$parkrun"\t"$event_index"\tA"$athleteId"\t"$Name
		echo -e $eventdate"\t"$parkrun"\t"$event_index"\tA"$athleteId"\t"$Name  >> "$volunteer_file"
	done
	
	sleep 1

done
