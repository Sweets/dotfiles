cd /users/sweets/.config/custard/schemes/in-love-with-a-ghost/

xset +fp /usr/share/fonts/envypn
xset fp rehash

xrdb -load ./Xresources
hsetroot -solid '#f0f0f0'
sh ./bars/start.sh &
sleep 2
urxvt -depth 32 -bg 'rgba:0000/0000/0000/0000' -geometry '274x78+0+36' -borderLess -override-redirect -internalBorder 0 -e cava -p ./cava &
xsetroot -cursor_name left_ptr
hsetroot -solid '#f0f0f0' -full ./wallpaper.jpg
sleep 2
compton --shadow-opacity 0 &
