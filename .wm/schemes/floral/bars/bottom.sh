#!/bin/bash

proc_dir="/tmp/lemonbar"

background_color="#191719"
foreground_color="#585258"
highlight_color="#656196"

font="-sweets-eclair-medium-r-normal--12-*-*-*-c-*-iso10646-1"
iconic_font="-Wuncon-Siji-Medium-R-Normal--10-100-75-75-c-80-iso10646-1"

geometry="1920x32+0+0"

configuration="-d -b -B $background_color -F $foreground_color -f $iconic_font -f $font -g $geometry"

#####

getsong() {

    last_value=`cat $proc_dir/mpd`

    completion_color=$highlight_color
    paused_color=$foreground_color

    delimiter=" - "

    song_string=`mpc current -f "[%artist%$delimiter%title%|%file%]"`
    song_status=`mpc status | awk -F "[][]" 'NR==2{print$2}'`

    percentage=`mpc | grep -o "(.*%)"`
    percentage=${percentage:1:-2}

    total_length=${#song_string}
    n_colored=$(( $(($percentage * $total_length)) / 100))

    output=""

    if [[ "$song_status" == "paused" ]]
    then
        output="%{F$paused_color}$song_string"
    else
        output="%{F$completion_color}"

        for (( index=0; index<$total_length; index++ ))
        do

            if [[ "$index" == "$n_colored" ]]
            then
                output="$output%{F-}"
            fi

            output="$output${song_string:$index:1}"

        done
    fi

    output="%{A:mpc prev:}%{A}%{A:mpc toggle:} $output %{F$foreground_color}%{A}%{A:mpc next:}%{A} "

    if [[ "$last_value" != "$output" ]]
    then
        echo "$output" > $proc_dir/mpd
    fi
}

getwindow() {

    last_value=`cat $proc_dir/window`

    id=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)" | awk '{print $5}')
    output=""

    if [[ "$id" != "0x0" ]]
    then
        name=$(xprop -id $id | grep "_NET_WM_NAME" | awk '{$1=$2=""; print $0}')
        output="%{F$highlight_color}${name:3:-1}%{F$foreground_color}"
    fi

    if [[ "$last_value" != "$output" ]]
    then
        echo "$output" > $proc_dir/window
    fi
}

windowmpd(){
    getsong
    getwindow
    sleep 0.5
}

bar_output(){
    last_value=`cat $proc_dir/last_output_bottom`

    window=`cat $proc_dir/window`
    mpd=`cat $proc_dir/mpd`

    output=" $window%{r}$mpd "

    echo "$output"
}

initbar(){
    mkfifo $proc_dir/vol_fifo 2> /dev/null
    touch $proc_dir/last_output_bottom
    touch $proc_dir/inet
    touch $proc_dir/vol
    touch $proc_dir/ws

    wrapper windowmpd &
}

##### DO NOT EDIT ANYTHING BELOW THIS LINE

wrapper(){
    while [[ true ]]
    do
        echo "`$@`" > /dev/null
        echo 'update' > $proc_dir/fifo
    done
}

bar(){

    mkdir -p $proc_dir
    mkfifo $proc_dir/fifo 2> /dev/null
    initbar

    while [[ true ]]
    do

        cat $proc_dir/fifo > /dev/null
        last_value=`cat $proc_dir/last_output_bottom`
        output=`bar_output`

        if [[ "$last_value" != "$output" ]]
        then
            printf '%s\n' "$output"
            echo "$output" > $proc_dir/last_output_bottom
        fi

    done

}

bar | lemonbar $configuration | sh

