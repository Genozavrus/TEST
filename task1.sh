#!/bin/bash


if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <путь_к_accounts.csv>"
    exit 1
fi


input_file=$1
output_file="accounts_new.csv"

if [ ! -f "$input_file" ]; then
    echo "Ошибка: Файл $input_file не найден!"
    exit 1
fi


> "$output_file"

remove_quotes() {
    echo "$1" | sed 's/^"//;s/"$//;s/""/"/g'
}


while IFS=',' read -r id location_id name position email; do
   
    if [ "$id" == "id" ]; then
        echo "$id,$location_id,name,position,email," >> "$output_file"
        continue
    fi

  
    id=$(remove_quotes "$id")
    location_id=$(remove_quotes "$location_id")
    name=$(remove_quotes "$name")
    position=$(remove_quotes "$position")
    email=$(remove_quotes "$email")

   
    name_cleaned=$(echo "$name" | awk '{
        split($0, a, " ")
        for (i in a) {
            a[i] = toupper(substr(a[i], 1, 1)) tolower(substr(a[i], 2))
        }
        print a[1] " " a[2]
    }')

 
    first_letter=$(echo "$name" | awk '{print tolower(substr($1, 1, 1))}')
    surname=$(echo "$name" | awk '{print tolower($2)}')

    
    if [ -z "$first_letter" ] || [ -z "$surname" ]; then
        email_new=""
    else
        email_base="${first_letter}${surname}@abc.com"
        if [ -z "$email" ]; then
            email_new="$email_base"
        else
            email_new="${first_letter}${surname}${location_id}@abc.com"
        fi
    fi

   
    echo "$id,$location_id,$name_cleaned,$position,$email_new," >> "$output_file"
done < "$input_file"

echo "Обработанные данные записаны в $output_file"
