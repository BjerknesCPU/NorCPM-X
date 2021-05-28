#!/bin/sh -e

ARCDIR=$1
INIDIR=/cluster/projects/nn9039k/inputdata/ccsm4_init
RESDAT=`basename $2 -00000`
PREFIX=`basename $ARCDIR`

for CASE in `ls $ARCDIR | grep $PREFIX`
do
  mkdir -p $INIDIR/$PREFIX/$CASE/$RESDAT
  cp -vfp $ARCDIR/$CASE/rest/${RESDAT}-00000/* $INIDIR/$PREFIX/$CASE/$RESDAT/
done 
echo COMPLETE
