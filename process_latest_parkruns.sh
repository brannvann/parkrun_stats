#!/bin/bash
# результаты и статистика волонтеров последних забегов parkrun russia

user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'

# Все забеги parkrun Россия
courses_page='https://www.parkrun.ru/results/courserecords/'
courses_src=$(curl -s -A "$user_agent" "$courses_page")
parkruns_russia=($(echo "$courses_src" |
				  tr -d '\n' |
                  awk -F'<tbody>' '{print $2}' |
                  awk -F'</tbody>' '{print $1}' |
                  sed 's/\/results">/\n/g' |
                  awk -F'<tr><td><a href="https://www.parkrun.ru/' '{print $2}'))

# Забеги последней недели
last_recorsd_page='https://www.parkrun.ru/results/firstfinishers/'
last_recorsd_src=$(curl -s -A "$user_agent" $last_recorsd_page )
last_events=($(echo "$last_recorsd_src" |
				tr -d '\n' |
                awk -F'<tbody>' '{print $2}' |
                awk -F'</tbody>' '{print $1}'|
                sed 's/\/results">/\n/g' |
                awk -F'<tr><td><a href="https://www.parkrun.ru/' '{print $2}'))

echo " ============ Забеги последней недели ==================="
for parkrun in "${last_events[@]}";
do
	echo $parkrun
done

event_last_page="https://www.parkrun.ru/"$last_events"/results/latestresults/"
last_date_src=$(curl -s -A "$user_agent" "$event_last_page")
last_date=$(echo "$last_date_src" |
				tr -d '\n' |
                awk -F'format-date\">' '{print $2}' |
                awk -F'<' '{print $1}'|
                awk -F'/' '{print $3$2$1}')
echo " ============== дата последнего забега =================="
echo "$last_date"

work_dir=$(dirname $0)

result_dir="results_"$last_date
if [[ ! -d "$result_dir" ]]; then
	echo "cоздаем" "$result_dir"
	mkdir "$result_dir"
fi
cd "$result_dir"

russia_all_results='_russia_all_results.txt'	
russia_latest_results='_russia_latest_results.txt'
echo -n > "$russia_all_results"		  
echo -n > "$russia_latest_results"		  

russia_all_volunteers='_russia_all_volunteers.txt'
russia_latest_volunteers='_russia_latest_volunteers.txt'
echo -n > "$russia_all_volunteers"
echo -n > "$russia_latest_volunteers"

missing_volunteers=''

for parkrun in "${last_events[@]}";
do
	event_all_results=$parkrun"_results.txt"
	event_latest_results=$parkrun"_latest.txt"
	event_all_volunteers=$parkrun"_volunteers.txt"
	event_latest_volunteers=$parkrun"_latest_volunteers.txt"
	
	is_last_results=0
	is_last_volunteers=0
	if [[ -f $event_latest_results ]]; then
		if grep -q -s "^$last_date" $event_latest_results; 
		then
			echo "результаты для "$parkrun" уже загружены"
			is_last_results=1
		fi
	fi
	if [[ -f $event_latest_volunteers ]]; then
		if grep -q -s "^$last_date" $event_latest_volunteers; 
		then
			echo "волонтеры для "$parkrun" уже загружены"
			is_last_volunteers=1
		fi
	fi
	
	if [[ "0" == "$is_last_results" || "0" == "$is_last_volunteers" ]]; then
		.${work_dir}/parkrun_results.sh "$parkrun" "$last_date"
	fi
	
	if [[ -f $event_all_results ]]; then
		cat "$event_all_results" >> "$russia_all_results"; 
	fi
	if [[ -f $event_all_volunteers ]]; then
		cat "$event_all_volunteers" >> "$russia_all_volunteers"
	fi
	
	#echo "проверка результатов на дату "$last_date
	is_last_results=0
	if [[ -f $event_latest_results ]]; then
		if grep -q "^$last_date" $event_latest_results; then
			is_last_results=1
		fi
	fi
	if [[ "1" == "$is_last_results" ]]; then
		#echo "последние результаты "$parkrun" ("$last_date") обработаны"
		cat "$event_latest_results" >> "$russia_latest_results"
	else
		echo "последних результатов "$parkrun" ("$last_date") еще нет!"
	fi
		
	is_last_volunteers=0
	if [[ -f $event_latest_volunteers ]]; then
		if grep -q "^$last_date" $event_latest_volunteers; then
			is_last_volunteers=1
		fi
	fi
	if [[ "1" == "$is_last_volunteers" ]]; then
		#echo "волонтеры последнего забега "$parkrun" ("$last_date") обработаны"
		cat "$event_latest_volunteers" >> "$russia_latest_volunteers"
	else  
		echo "информации о волонтeрах последнего "$parkrun" ("$last_date") еще нет!"
		missing_volunteers=$missing_volunteers" "$parkrun
	fi

	sleep 1
done

echo "========================================================="
if [ -n "$missing_volunteers" ]
then
	echo "на дату "$last_date" нет информации о волонтерах для забегов: "
	echo $missing_volunteers
fi

missing_events=$(echo ${parkruns_russia[@]} ${last_events[@]} | tr ' ' '\n' | sort | uniq -u) 
echo "Нет результатов для забегов: "$missing_events
