#!/bin/bash
BAN_FILE="banlist.txt"

format() {
	file="$1"
	if [ ! -f "$file" ]; then
		echo "Файл не найдет: $file" >&2 #перенаправляем в поток ошибок
		return 1
	fi
	tmp="${file}.tmp"
	if sed '/^11_Steve_11[[:space:]]/d' "$file" | sort -u > "$tmp"; then #ищем все строки нач ^ c стив после рег выражение и пробел чтобы не удалить схожий ник, /d - delete
        mv "$tmp" "$file" 
    else
        rm -f "$tmp" #remove tmp выходим с ошибкой 1
        return 1
    fi 
	#sort -u замена sort |uniq 
	
}

add() {
	#---------проверка на сущ файла-----------
	if [ ! -f "$BAN_FILE" ]; then #если не существует файла с банами add создает его
		touch "$BAN_FILE"
	fi
	#---------передача значения в функцию-------------
	if [ "$#" -eq 1 ]; then
		line="$1"
		nickname="${line%% *}" #%% - ищет самое длинное совпадение :% - самое короткое. " *" - паттерн пробел что угодно 
		prom="${line#* }" #: # - противоположность % смотрит с начала и мы удаляем что угодно и до первого пробела самое короткое
		time="${prom%% *}"
		reason="${prom#* }"
	elif [ "$#" -ge 3 ]; then #greater or equal -ge
		nickname="$1"
		time="$2"
		shift 2 #тк в reason передается не одно слово нужно сдвинуть влево на две позиции чтобы затереть nick & time и приминяем $* все знаяения 
		reason="$*"
	else
		echo "Передайте данные: nickname, time, reason">&2  
		return 1
	fi
	#---------проверка на пустые значения в переменных -----------
	if [ -z "$nickname" ] || [ -z "$time" ] || [ -z "$reason" ]; then
		echo "Переданы пустые значения"
		return 2 #2 - код пустого значения
	fi
	#---------check for existence/проверка на существование в файле BAN---------- 
	if sed 's/[[:space:]].*$//' "$BAN_FILE" | grep -Fxq "$nickname"; then #грепаем значение переменной ник нэйм из изм бан файла||| -F(fixed) - заставляем грепать с спец символами, -x - совпадение всей строки, -q(quiet) - тихий режим без вывода в консоль
		echo "Player is already on the ban list">&2
		return 3 
	fi 
	  #s - substitute - замена  мы ищем пробел и после него бесконечное количество символов . - любой символ
	# --- * повторить пред команду бесконечное колво раз. // первый слеш разделитель после того что ищем второй закрывающий -  меняем найденую строку на пустоту
	# $ конец строки 
	printf '%s %s %s\n' "$nickname" "$time" "$reason" >> "$BAN_FILE" #печатаем значения в бан файл 
}

info () {
	nickname="$1"
	sed -n "/^${nickname}[[:space:]]/p" "$BAN_FILE" #-n заставляет sed не выводить строку пока не выполнится регулярка оператор p -print ищем значение ник+' '
}
remove() {
	nickname="$1"
	tmp="${BAN_FILE}.tmp" #временный файл
	if sed "/^${nickname}[[:space:]]/d" "$BAN_FILE" > "$tmp"; then
        mv "$tmp" "$BAN_FILE"
    fi
}

sortList () {
	option="$1"
	outfile="$2"
	tmp="${outfile}.tmp"

	case "$option" in
		--name)
			sort -k1,1 "$BAN_FILE" > "$tmp"
			;;
		--time) 
			sort -t' ' -k2.7,2.10n -k2.4,2.5n -k2.1,2.2n "$BAN_FILE" > "$tmp"
			;;
		*)
			echo "">&2
			return 4
			;;
	esac
	mv "$tmp" "$outfile"
}		

case "$1" in
	format)
		[ "$#" -eq 2 ] || exit 1 # - смотрит если передано два знач команда + файл 
		format "$2"
		;;
	add) 
		shift 
		add "$@"
		;;
	info)
		[ "$#" -eq 2 ] || exit 1
		info "$2"
		;;
	remove) 
		[ "$#" -eq 2 ] || exit 1
		remove "$2"
		;;
	sort) 
		[ "$#" -eq 3 ] || exit 1
		sortList "$2" "$3"
		;;
	*)
		echo "Неизвестная команда">&2
		exit 1
		;;

esac
