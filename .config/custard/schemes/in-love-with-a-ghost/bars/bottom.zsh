#!/bin/zsh

geometry="1920x32+0+0"
background_color="#252422"
foreground_color="#80746f"
font="-ypn-envypn-Medium-R-Normal--13-130-75-75-c-90-iso8859-1"
#font="-lucy-tewi-Medium-R-Normal--11-90-75-75-p-58-iso10646-1"
iconic_font="-Wuncon-Siji-Medium-R-Normal--10-100-75-75-c-80-iso10646-1"

getsong() {

    completion_color="#dc1566"
    paused_color="#d7d787"

    delimiter=" - "

    song_string=$(mpc current -f "[%title%$delimiter%artist%|%file%] ")
    song_status=$(mpc status | awk -F "[][]" 'NR==2{print $2}')

    percentage=$(mpc | grep -o "(.*%)")
    percentage=${percentage:1:-2}

    total_length=${#song_string}
    n_colored=$(( $(($percentage * $total_length)) / 100 ))

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
                output="${output}%{F-}"
            fi

            output="${output}${song_string:$index:1}"

        done

    fi

    echo "$output%{F-}"

}

getwindows() {
    windows=$(lsw)
    namestr=""

    if [[ "$windows" != "" ]]
    then
        while IFS="\n" read arr
        do
            for i in $arr[@]
            do
                name=$(xprop -id $i | grep "WM_COMMAND" | awk '{print $4}')
                # Using xprop for the "name" (I realize WM_COMMAND isn't the name, but
                # for some reason windows names just disappear into thin air after a while)
                name="${name:1:-1}"
                if [[ "$i" == "$(pfw)" ]]
                then
                    name="%{F#bc7252}$name%{F#80746f}"
                fi
                namestr="$namestr $name"
            done
        done <<< $windows
    fi
    echo $namestr

}

bar() {
    while [[ true ]]
    do
        printf "%s\n" " $(getwindows)%{r}$(getsong)"
        sleep 0.5
    done
}

bar | lemonbar -d -B "$background_color" -F "$foreground_color" -f "$iconic_font" -f "$font" -g "$geometry" -b | sh

