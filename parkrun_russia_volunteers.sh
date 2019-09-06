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
 kurgancentralpark
)
		  
short_events=(chelyabinskekopark zatyumensky orskparkstroiteley)		  
		  
russia_full_stat='russia_full_stat.txt'
echo -n > $russia_full_stat		  

volunteers_russia='volunteers_russia.txt'
echo -n > $volunteers_russia
		  
d=$(dirname $0)

#for parkrun in "${short_events[@]}"; 
for parkrun in "${events[@]}";
do
	event_full_stat=$parkrun'_full_stat.txt'
	event_volunteers='volunteers_'$parkrun'.txt'
	
	. ${d}/prun_stat.sh $parkrun
	
	cat $event_full_stat >> $russia_full_stat
	cat $event_volunteers >> $volunteers_russia
done
