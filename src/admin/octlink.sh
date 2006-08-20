#! /bin/sh

FN2=`echo $2 | sed -e's/.octlink//'`
FN1=`echo $1 | sed -e's/.oct//'`
if test -e $2 ; then /bin/rm $2; fi
echo "autoload (\"$FN2\", which (\"$FN1\"));" > $2
