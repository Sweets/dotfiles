#!/bin/bash

file="$1"
cmd="${@:2}"

exe_cmd(){
    output=`sh -c "$@"`
    printf '%s\n' "$output"
}

awaitchange(){

    original=`exe_cmd "$cmd"`
    newest=""

    waiting=true

    while [[ "$waiting" == "true" ]]
    do
        cat $file > /dev/null
        newest=`exe_cmd "$cmd"`

        if [[ "$newest" != "$original" ]]
        then
            waiting=false
        fi

    done

    printf '%s\n' "$newest"

}

run(){
    mkfifo "$file"
    printf '%s\n' "`awaitchange "$cmd"`"
    rm "$file"
}

run
