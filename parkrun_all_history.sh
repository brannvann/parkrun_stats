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
 severnyrechnoyvokzal ekaterinburgzelenayaroscha
)

work_dir=$(dirname $0)
history_dir='all_history'

if [[ ! -d "$history_dir" ]]; then
	echo "cоздаем" "$history_dir"
	mkdir "$history_dir"
fi
cd "$history_dir"

russia_all_history='_russia_all_history.txt'
echo -n > "$russia_all_history"	

for parkrun in "${events[@]}";
do
	event_history=$parkrun"_history.txt"
	.${work_dir}/parkrun_history.sh "$parkrun"
	cat "$event_history" >> "$russia_all_history"
done	



