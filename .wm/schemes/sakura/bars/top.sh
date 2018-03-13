#!/bin/bash

proc_dir="/tmp/lemonbar"

background_color="#191719"
foreground_color="#585258"
highlight_color="#de7a8c"

font="-sweets-eclair-medium-r-normal--12-*-*-*-c-*-iso10646-1"
iconic_font="-Wuncon-Siji-Medium-R-Normal--10-100-75-75-c-80-iso10646-1"

geometry="1920x32+0+0"

configuration="-d -B $background_color -F $foreground_color -f $iconic_font -f $font -g $geometry"

#####

getws(){

    last_value=`cat $proc_dir/ws`

    output=""

    file="$proc_dir/ws_monitor"
    currentws=`sh /users/grace/.wm/schemes/sakura/bars/await.sh $file "xprop -root | grep '_NET_CURRENT_DESKTOP(CARDINAL)'"`
    currentws=`echo "$currentws" | awk '{print $3}'`
    numws=$(xprop -root | grep "_NET_NUMBER_OF_DESKTOPS(CARDINAL)" | awk '{print $3}')

    echo "$currentws $numws" > /tmp/output

    index="0"

    icon=""

    while [[ "$(($index < $numws))" == "1" ]]
    do
        if [[ "$index" == "$currentws" ]]
        then
            output="$output%{F$highlight_color}$icon%{F$foreground_color}"
        else
            output="$output$icon"
        fi
        index=$(($index + 1))
    done

    if [[ "$last_value" != "$output" ]]
    then
        echo "$output" > $proc_dir/ws
    fi

}

inet(){

    last_value=`cat $proc_dir/inet`

    interface=$(ip route | head -n 1 | awk '{print $5}')

    if [[ "$interface" == 'enp3s0' ]]
    then

        icon="%{F$highlight_color}%{F$foreground_color}"

    else
        # Note: implement this
        echo '' > /dev/null

    fi

    if [[ "$last_value" != "$icon" ]]
    then
        echo "$icon" > $proc_dir/inet
    fi

    sleep 0.5

}

clock(){
    echo "`date +'%a %b %d, %H:%M'`" > $proc_dir/clock
    sleep 60
}

quote(){
    echo "%{F$highlight_color}You'll never find beauty if you don't first find change.%{F$foreground_color}"
}

volume(){

    last_value=`cat $proc_dir/vol`

    file="$proc_dir/vol_monitor"
    vol=`sh /users/grace/.wm/schemes/sakura/bars/await.sh $file "amixer get Master"`

    frontleft=$(echo -e "$vol" | grep "Front Left:")
    frontright=$(echo -e "$vol" | grep "Front Right:")

    leftvol=$(echo -e "$frontleft" | awk '{print $5}')
    rightvol=$(echo -e "$frontright" | awk '{print $5}')

    leftstatus=$(echo -e "$frontleft" | awk '{print $6}')
    rightstatus=$(echo -e "$frontright" | awk '{print $6}')

    leftvol="${leftvol:1:-2}"
    rightvol="${rightvol:1:-2}"

    avg="$(( $(( $leftvol + $rightvol )) / 2 ))"

    if [[ "$leftstatus" == "$rightstatus" && "$leftstatus" == "[on]" ]]
    then

        icon="%{F$highlight_color}"

        if [[ "$(($avg > 67))" == "1" ]]
        then
            icon="$icon"
        elif [[ "$(($avg > 33))" == "1" ]]
        then
            icon="$icon"
        elif [[ "$(($avg > 0))" == "1" ]]
        then
            icon="$icon"
        else
            icon="$icon"
        fi

        icon="$icon%{F$foreground_color}"

    else
        icon=""
    fi

    if [[ "$icon" != "$last_value" ]]
    then
        echo "$icon" > $proc_dir/vol
    fi

}

bar_output(){

    con=`cat $proc_dir/inet`
    vol=`cat $proc_dir/vol`
    ws=`cat $proc_dir/ws`

    output=" $ws%{c}`quote`%{r}$con $vol "

    echo "$output"
}

initbar(){
    mkfifo $proc_dir/vol_fifo 2> /dev/null
    touch $proc_dir/last_output_top
    touch $proc_dir/inet
    touch $proc_dir/vol
    touch $proc_dir/ws

    wrapper volume &
    wrapper inet &
    wrapper getws &
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

        last_value=`cat $proc_dir/last_output_top`
        output=`bar_output`

        if [[ "$last_value" != "$output" ]]
        then
            printf '%s\n' "$output"
            echo "$output" > $proc_dir/last_output_top
        fi

    done

}

bar | lemonbar $configuration | sh

