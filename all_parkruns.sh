#!/bin/bash
# Get names of all russian parkruns
# This script updates file parkrun_russia.txt

courses_page='https://www.parkrun.ru/results/courserecords/'
user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0'

courses_src=$(curl -s -A "$user_agent" $courses_page)
parkruns_russia=$(echo "$courses_src" |
                  tr -d '\n' |
                  awk -F'<tbody>' '{print $2}' |
                  awk -F'</tbody>' '{print $1}' |
                  sed 's/\/results">/\n/g' |
                  awk -F'<tr><td><a href="https://www.parkrun.ru/' '{print $2}')
echo "Number of parkruns in Russia: ""$(wc -l "$parkruns_russia")"
echo "$parkruns_russia" > parkruns_russia.txt
