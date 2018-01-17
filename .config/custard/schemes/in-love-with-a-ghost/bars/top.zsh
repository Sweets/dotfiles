#!/bin/zsh

geometry="1920x32+0+0"
background_color="#252422"
foreground_color="#80746f"
font="-ypn-envypn-Medium-R-Normal--13-130-75-75-c-90-iso8859-1"
#font="-lucy-tewi-Medium-R-Normal--11-90-75-75-p-58-iso10646-1"
iconic_font="-Wuncon-Siji-Medium-R-Normal--10-100-75-75-c-80-iso10646-1"

getws() {
    wsa=""
    currentws=$(xprop -root | grep "_NET_CURRENT_DESKTOP(CARDINAL)" | awk '{print $3}')
    numws=$(xprop -root | grep "_NET_NUMBER_OF_DESKTOPS(CARDINAL)" | awk '{print $3}')

    i=0

    icon="î†‘"

    while [[ "$(($i < $numws))" == "1" ]]
    do
        if [[ "$i" == "$currentws" ]]
        then
            wsa="$wsa%{F#bc7252}$icon%{F#80746f}"
        else
            wsa="$wsa$icon"
        fi
        i=$(($i + 1))
    done

    echo $wsa

}

wifi() {

    # First check if we're connected to anything

    icon="îˆŸ"
    SSID=$(iwconfig wlp2s0 | grep -o "ESSID:.*" | sed 's/ESSID://g')
    SSID="${SSID:0:-2}"

    if [[ "$SSID" != "off/any" ]]
    then

        SSID="${SSID:1:-1}"

        SIGNAL=$(nmcli -t -f signal,ssid dev wifi | grep "$SSID" | awk -F : '{print $1}')

        icon="%{F#bc7252}"

        if [[ "$(($SIGNAL > 75))" == "1" ]]
        then
            icon="$iconîˆ¢"
        elif [[ "$(($SIGNAL > 50))" == "1" ]]
        then
            icon="$iconîˆ¡"
        elif [[ "$(($SIGNAL > 25))" == "1" ]]
        then
            icon="$iconîˆ "
        else
            icon="$iconîˆŸ"
        fi

        icon="$icon%{F#80746f}"

    else
    fi

    echo $icon

}

volume() {

    icon="î"

    vol=$(amixer get Master)

    frontleft=$(echo $vol | grep "Front Left:")
    frontright=$(echo $vol | grep "Front Right:")

    leftvol=$(echo $frontleft | awk '{print $5}')
    rightvol=$(echo $frontright | awk '{print $5}')

    leftstatus=$(echo $frontleft | awk '{print $6}')
    rightstatus=$(echo $frontright | awk '{print $6}')

    leftvol="${leftvol:1:-2}"
    rightvol="${rightvol:1:-2}"

    avg=""
    avg=$(( $(( $leftvol + $rightvol )) / 2 ))

    if [[ "$leftstatus" == "$rightstatus" && "$leftstatus" == "[on]" ]]
    then

        icon="%{F#bc7252}"

        if [[ "$(($avg > 67))" == "1" ]]
        then
            icon="$iconî"
        elif [[ "$(($avg > 33))" == "1" ]]
        then
            icon="$iconî"
        elif [[ "$(($avg > 0))" == "1" ]]
        then
            icon="$iconîŽ"
        else
            icon="$iconî"
        fi

        icon="$icon%{F#80746f}"

    fi

    echo $icon

}

datetime() {

    echo "$(date +'%a %b %d, %H:%M') "

}

placeholder() {

    echo "%{A:urxvt:}î†‘î†‘î†‘%{A}"

}

bar() {
    while [[ true ]]
    do
        printf "%s\n" " $(getws)%{c}$(datetime)%{r}$(wifi) $(volume) "
        sleep 0.5
    done
}

bar | lemonbar -d -B "$background_color" -F "$foreground_color" -f "$iconic_font" -f "$font" -g "$geometry" | sh

