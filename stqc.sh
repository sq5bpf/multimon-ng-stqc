#!/bin/bash
# Simple STQC Encoder (c) 2013 Jacek Lipkowski <sq5bpf@lipkowski.org>
#
# This was only a proof of concept, and i really should rewrite this in C,
# but it serves it's purpose well
#

if [ $# -lt 2 ]; then 
cat <<EOF
Simple STQC Encoder  (c) 2013 Jacek Lipkowski <sq5bpf@lipkowski.org>

Usage:
$0 <number_of_tones> <stqc sequence>

Where:
<number_of_tones> - usually 7 (for device address) or 8 (for command)
<stqc sequence> - sequence to be transmitted

Example:

$0 8 1234
(displays the tone frequencies and outputs a file named stqc8_1234.wav)

EOF

exit 1
fi

A=`echo "obase=4; $2"|bc -l `
B=`printf "%.${1}i" $A`
echo -n "$2: "

L=$1
PREV=980
while [ "$L" -gt 0 ]; do
C=`echo -n $B|tail -c $L|head -c 1`
case "$C" in
0) F=980 ;;
1) F=1197 ;;
2) F=1446 ;;
3) F=1795 ;;
esac
[ "$F" = "$PREV" ] && F=2105
PREV=$F
TON[$L]=$F
let L--
done
P=1
for i in `seq $1 -1 1`
do
echo -n "${TON[$i]} "
sox -r 8000 -b 16 -n ton_${P}.wav synth 0.1 sin ${TON[$i]}
let P++
done
echo
sox ton_*.wav stqc${1}_${2}.wav
rm ton_*.wav

