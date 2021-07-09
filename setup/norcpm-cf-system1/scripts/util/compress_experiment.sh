#!/bin/sh -e

SETUPROOT=`readlink -f \`dirname $0\``
if [[ `basename $SETUPROOT` == "core" || `basename $SETUPROOT` == "util" ]]
then
  SETUPROOT=`dirname \`dirname $SETUPROOT\``
fi
. $SETUPROOT/scripts/core/source_settings.sh $*

for MEMBER in `seq -w $MEMBER1 $MEMBERN`
do
  CASE=${ENSEMBLE_PREFIX}_${MEMBERTAG}${MEMBER}
  if (( $NO_START_DATE ))
  then
    DOUT_S_ROOT=$WORK/archive/$ENSEMBLE_PREFIX/$CASE
  else
    DOUT_S_ROOT=$WORK/archive/$CASE_PREFIX/$ENSEMBLE_PREFIX/$CASE
  fi
  $SETUPROOT/../../tools/noresm2nc4mpi/noresm2nc4mpi.${MACH}.sh $DOUT_S_ROOT
done

echo COMPLETE
