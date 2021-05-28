#!/bin/sh -e

ENSDIR=$1
RESDAT=$2
PREFIX=`basename $ENSDIR`
ARCDIR=`dirname \`dirname $ENSDIR\``/archive/$PREFIX 

for CASE in `ls $ENSDIR | grep $PREFIX`
do 
  echo "cd $ENSDIR/$CASE/run"
  cd $ENSDIR/$CASE/run
  echo "rm -f ${CASE}* rpointer* core*" 
  rm -f ${CASE}* rpointer* core*
  echo "ln $ARCDIR/$CASE/rest/$RESDAT/${CASE}* ."
  ln $ARCDIR/$CASE/rest/$RESDAT/${CASE}* .
  echo "cp $ARCDIR/$CASE/rest/$RESDAT/rpointer* ."
  cp $ARCDIR/$CASE/rest/$RESDAT/rpointer* .
done 
