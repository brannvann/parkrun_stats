#!/bin/bash
# статистика волонетров на всех забегах parkrun russia

events=( angarskieprudy babushkinskynayauze balashikhazarechnaya belgorodparkpobedy
 bitsa butovo cheboksarynaberezhnaya chelyabinsk chelyabinskekopark chertanovopokrovskypark
 dolgoprudny druzhba ekaterinburgzelenayaroscha elaginostrov gatchinaprioratsky
 gorkypark izmailovo kazancentral khimki kimry kolchuginocitypark kolomenskoe
 kolpino korolev krasnoyarsknaberezhnaya krylatskoe 
 kuzminki megaparkkudrovo meshchersky mitino moskovskyparkpobedy natashinsky
 nizhnynovgorodmeshchersky novosibirsknaberezhnaya obninsk olimpiyskayaderevnya
 orskparkstroiteley parkguskova pavlovskyposad permbalatovo petergofaleksandriysky 
 pokrovskoestreshnevo pushkin readovskypark rostovondon ryazancentral ryazanoreshek 
 samaraparkgagarina serpukhovgorodskoybor severnoetushino severnyrechnoyvokzal 
 shuvalovskypark sokolniki sosnovka stavropol tambov timiryazevsky tsaritsyno 
 tulacentral ufabotanicheskysad velikiynovgorodkremlevsky vernadskogo volgogradpanorama
 voronezhcentralpark yakutskdokhsun zatyumensky zelenograd zhukovsky
 kurgancentralpark staryesady
)

result_dir='latest'
if [[ -n "$1" ]]; then
	result_dir="$1"
fi

if [[ ! -d "$result_dir" ]]; then
	echo "не найден каталог с результатами " "$result_dir"
	exit
fi
cd "$result_dir"

russia_all_volunteers='russia_all_volunteers.txt'		  
russia_latest_volunteers='russia_latest_volunteers.txt'
echo -n > $russia_all_volunteers
echo -n > $russia_latest_volunteers		  

russia_latest_results='russia_latest_results.html'
echo -n > $russia_latest_results
		  
for parkrun in "${events[@]}";
do
	event_all_volunteers=$parkrun'_all_volunteers.txt'
	event_latest_volunteers=$parkrun'_latest_volunteers.txt'
	
	event_all_results=$parkrun'_all_results.html'
	event_latest_results=$parkrun'_latest_results.html'
	
	cat $event_latest_volunteers >> $event_all_volunteers
	cat $event_latest_results >> $event_all_results
	
	cat $event_latest_results >> $russia_latest_results
	cat $event_latest_volunteers >> $russia_latest_volunteers
	cat $event_all_volunteers >> $russia_all_volunteers
done
