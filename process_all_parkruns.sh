#!/bin/bash
# результаты и статистика волонтеров на прошедших забегах parkrun russia

events=( angarskieprudy babushkinskynayauze balashikhazarechnaya belgorodparkpobedy
  cheboksarynaberezhnaya chelyabinsk chelyabinskekopark chertanovopokrovskypark
 dolgoprudny druzhba elaginostrov gatchinaprioratsky
 gorkypark izmailovo kazancentral khimki kimry kolchuginocitypark kolomenskoe
 kolpino korolev krasnoyarsknaberezhnaya krylatskoe 
 kuzminki megaparkkudrovo meshchersky mitino moskovskyparkpobedy natashinsky
 nizhnynovgorodmeshchersky novosibirsknaberezhnaya obninsk olimpiyskayaderevnya
 orskparkstroiteley parkguskova pavlovskyposad permbalatovo petergofaleksandriysky 
 pokrovskoestreshnevo pushkin readovskypark rostovondon ryazancentral ryazanoreshek 
 samaraparkgagarina serpukhovgorodskoybor severnoetushino 
 shuvalovskypark sokolniki sosnovka stavropol tambov timiryazevsky tsaritsyno 
 tulacentral ufabotanicheskysad velikiynovgorodkremlevsky vernadskogo volgogradpanorama
 voronezhcentralpark yakutskdokhsun zatyumensky zelenograd zhukovsky
 kurgancentralpark staryesady tomskstadionpolytechnic lesoparkseverny solnechnyostrov
 skverdzerzhinskogo noginskgorodskoypark bitsa butovo plotinka
)

work_dir=$(dirname $0)
result_dir='all_results'

last_date=''
no_events=()

if [[ -n "$1" ]]; then
	last_date="$1"
	result_dir="results_"$last_date
else
	#архивные паркраны
	events=("${events[@]}" "ekaterinburgzelenayaroscha")
	events=("${events[@]}" "severnyrechnoyvokzal")
fi

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

missing_evetns=''
missing_volunteers=''

for parkrun in "${events[@]}";
do
	event_all_results=$parkrun"_results.txt"
	event_latest_results=$parkrun"_latest.txt"
	event_all_volunteers=$parkrun"_volunteers.txt"
	event_latest_volunteers=$parkrun"_latest_volunteers.txt"
	
	is_last_results=0
	is_last_volunteers=0
	if [ -n "$last_date" ]
	then
		if grep -q "^$last_date" $event_latest_results; 
		then
			echo "результаты для "$parkrun" уже загружены"
			is_last_results=1
		fi
		if grep -q "^$last_date" $event_latest_volunteers; 
		then
			echo "волонтеры для "$parkrun" уже загружены"
			is_last_volunteers=1
		fi
	fi
	
	if [[ "0" == "$is_last_results" || "0" == "$is_last_volunteers" ]]; then
		.${work_dir}/parkrun_results.sh "$parkrun" "$last_date"
	fi
	
	cat "$event_all_results" >> "$russia_all_results"
	cat "$event_all_volunteers" >> "$russia_all_volunteers"
	
	if [ -n "$last_date" ]	
	then
		#echo "проверка результатов на дату "$last_date
		if grep -q "^$last_date" $event_latest_results; 
		then
			echo "последние результаты "$parkrun" ("$last_date") обработаны"
			cat "$event_latest_results" >> "$russia_latest_results"
		else  
			echo "последних результатов "$parkrun" ("$last_date") еще нет!"
			missing_evetns=$missing_evetns" "$parkrun
		fi
		if grep -q "^$last_date" $event_latest_volunteers; 
		then
			echo "волонтеры последнего забега "$parkrun" ("$last_date") обработаны"
			cat "$event_latest_volunteers" >> "$russia_latest_volunteers"
		else  
			echo "информации о волонетрах последнего "$parkrun" ("$last_date") еще нет!"
			missing_volunteers=$missing_volunteers" "$parkrun
		fi
	fi

	sleep 1
done

if [ -n "$last_date" ]
then
	echo "на дату "$last_date" нет результатов для забегов:"
	echo $missing_evetns
	
	echo "на дату "$last_date" нет информации о волонтерах для забегов:"
	echo $missing_volunteers
fi
