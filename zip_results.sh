#!/bin/bash
# сохранить содержимое all_results в архив

last_date='latest'
if [[ -n "$1" ]]; then
	last_date="$1"
fi
	
zipname="all_results/results."$last_date".zip"

zip $zipname all_results/*.txt	
