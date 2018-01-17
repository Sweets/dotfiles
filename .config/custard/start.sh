
scheme="$1"

echo "" > /tmp/custard.log
sh /users/sweets/.config/custard/schemes/$scheme/start.sh
sxhkd -c /users/sweets/.config/custard/sxhkdrc &
custard >> /tmp/custard.log
