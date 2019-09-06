#!/bin/bash
# результаты и статистика волонтеров на прошедших забегах parkrun russia

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
 kurgancentralpark
)
	
short_events=(chelyabinskekopark zatyumensky orskparkstroiteley)		  
		  
russia_latest_results='russia_latest_results.html'
echo -n > $russia_latest_results		  

russia_latest_volunteers='russia_latest_volunteers.txt'
echo -n > $russia_latest_volunteers
		  
d=$(dirname $0)

#for parkrun in "${short_events[@]}"; 
for parkrun in "${events[@]}";
do
	event_latest_results=$parkrun'_latest_results.html'
	event_latest_volunteers=$parkrun'_latest_volunteers.txt'
	
	. ${d}/parkrun_latest_results.sh $parkrun
	
	cat $event_latest_results >> $russia_latest_results
	cat $event_latest_volunteers >> $russia_latest_volunteers
done

