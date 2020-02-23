#!/bin/bash
#корректировка таблицы результатов. Преобразование 1:0X:XX в 6X:XX
#удаление лишних пробелов в конце полей с количеством забегов

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
 skverdzerzhinskogo noginskgorodskoypark bitsa butovo plotinka ekaterinburgzelenayaroscha
 severnyrechnoyvokzal
)

work_dir=$(dirname $0)
result_dir='all_results'
cd "$result_dir"

temp_file="_processed_results.txt"
for parkrun in "${events[@]}";
do
	result_file=$parkrun"_results.txt"
	latest_result_file=$parkrun"_latest.txt"
	
	#корректировка таблицы результатов. 
	for(( i=0; i<=9; i++ ))
	do
		# удаление лишних пробелов в конце полей с количеством забегов
		sed 's/'"$i"' /'"$i"'/' "$result_file" > "$temp_file"
		cat "$temp_file" > "$result_file"
		sed 's/'"$i"' /'"$i"'/' "$latest_result_file" > "$temp_file"
		cat "$temp_file" > "$latest_result_file"
			
		# преобразование 1:0X:XX в 6X:XX, 1:1X:XX в 7Х:ХХ, 1:2Х:ХХ в 8Х:ХХ
		sed 's/1:0'"$i"':/6'"$i"':/' "$result_file" > "$temp_file"
		cat "$temp_file" > "$result_file"
		sed 's/1:1'"$i"':/7'"$i"':/' "$result_file" > "$temp_file"
		cat "$temp_file" > "$result_file"
		sed 's/1:2'"$i"':/8'"$i"':/' "$result_file" > "$temp_file"
		cat "$temp_file" > "$result_file"
		
		sed 's/1:0'"$i"':/6'"$i"':/' "$latest_result_file" > "$temp_file"
		cat "$temp_file" > "$latest_result_file"
		sed 's/1:1'"$i"':/7'"$i"':/' "$latest_result_file" > "$temp_file"
		cat "$temp_file" > "$latest_result_file"
		sed 's/1:2'"$i"':/8'"$i"':/' "$latest_result_file" > "$temp_file"
		cat "$temp_file" > "$latest_result_file"
	done
done	
