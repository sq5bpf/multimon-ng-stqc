#!/bin/bash
# Simple STQC Encoder2 (c) 2014 Jacek Lipkowski <sq5bpf@lipkowski.org>
#
# This encoder generates the whole sequence: 7 tone address, 200ms silence, 8 tone command
#
# This was only a proof of concept, and i really should rewrite this in C,
# but it serves it's purpose well
#

if [ $# -lt 2 ]; then 
cat <<EOF
Simple STQC Encoder2  (c) 2014 Jacek Lipkowski <sq5bpf@lipkowski.org>

Usage:
$0 <stqc address> <stqc sequence>

Where:
<stqc address> - address of stqc device
<stqc sequence> - sequence to be transmitted

Example:

$0 321 1234
(displays the tone frequencies and outputs a file named stqc321_1234.wav)

EOF

exit 1
fi

# makes stqc sequence, arguments:
# $1 - outfile, $2 - sequence, $3 - length sequence length
make_stqc() {
A=`echo "obase=4; $2"|bc -l `
B=`printf "%.${3}i" $A`
echo -n "$2: "

L=$3
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
for i in `seq $3 -1 1`
do
echo -n "${TON[$i]} "
sox -r 8000 -b 16 -n ton_${P}.wav synth 0.1 sin ${TON[$i]}
let P++
done
echo
sox ton_*.wav $1
rm ton_*.wav
}

STQC_ADDR=$1
STQC_COMMAND=$2

TMPFILE1=$$_$1.wav
TMPFILE2=$$_$2.wav

make_stqc $TMPFILE1 $STQC_ADDR 7
make_stqc $TMPFILE2 $STQC_COMMAND 8
sox -n -r 8000  silence.wav trim 0.0 0.2
sox $TMPFILE1 silence.wav $TMPFILE2 stqc_${1}_${2}.wav
rm $TMPFILE1 silence.wav $TMPFILE2



