#!/bin/bash

# Проверяем, передан ли путь к файлу
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <путь_к_accounts.csv>"
    exit 1
fi

# Определяем входной и выходной файлы
input_file=$1
output_file="accounts_new.csv"

# Проверяем, существует ли входной файл
if [ ! -f "$input_file" ]; then
    echo "Ошибка: Файл $input_file не найден!"
    exit 1
fi

# Создаём или очищаем выходной файл
> "$output_file"

# Функция для удаления кавычек из строки
remove_quotes() {
    echo "$1" | sed 's/^"//;s/"$//;s/""/"/g'
}

# Обрабатываем входной файл построчно
while IFS=',' read -r id location_id name position email; do
    # Пропускаем заголовок
    if [ "$id" == "id" ]; then
        echo "$id,$location_id,name,position,email," >> "$output_file"
        continue
    fi

    # Удаление кавычек из данных
    id=$(remove_quotes "$id")
    location_id=$(remove_quotes "$location_id")
    name=$(remove_quotes "$name")
    position=$(remove_quotes "$position")
    email=$(remove_quotes "$email")

    # Приведение имени к требуемому формату
    name_cleaned=$(echo "$name" | awk '{
        split($0, a, " ")
        for (i in a) {
            a[i] = toupper(substr(a[i], 1, 1)) tolower(substr(a[i], 2))
        }
        print a[1] " " a[2]
    }')

    # Генерация email
    first_letter=$(echo "$name" | awk '{print tolower(substr($1, 1, 1))}')
    surname=$(echo "$name" | awk '{print tolower($2)}')

    # Проверка на пустое имя или некорректные данные
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

    # Запись строки в выходной файл
    echo "$id,$location_id,$name_cleaned,$position,$email_new," >> "$output_file"
done < "$input_file"

echo "Обработанные данные записаны в $output_file"
