
#xwinwrap -g 1920x1080 -ni -s -nf -b -un -argb -sh rectangle -fdt -- mpv -wid WID --keepaspect=no --loop /users/grace/.wm/schemes/sakura/wallpaper.webm &

xwinwrap -g 1920x1080 -ni -s -nf -b -un -argb -sh rectangle -fdt -- gifview -w WID -a /users/grace/.wm/schemes/sakura/wallpaper.gif &

glava &
sh /users/grace/.wm/schemes/sakura/bars/top.sh &
sh /users/grace/.wm/schemes/sakura/bars/bottom.sh &
compton --config /users/grace/.wm/schemes/sakura/compton.conf &

