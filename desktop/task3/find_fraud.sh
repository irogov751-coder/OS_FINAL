#!/bin/bash
if [ "$#" -ne 1 ]; then #принимает количество аргументов переданное в программу

	echo "Usage: $0 <transactions.log>" >&2 #redirects/перенаправляет the log to errors
	exit 1
fi
awk '
{
	from  = $1
	to = $3
	count =  $4
	expensesFirst[from]+=count
	profit[to]+=count
}

END {
	for(player in expensesFirst){
		if(expensesFirst[player]>profit[player]){
			print player
		}
	}
} 
' "$1"
