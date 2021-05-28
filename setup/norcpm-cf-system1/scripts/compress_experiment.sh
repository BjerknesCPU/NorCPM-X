#!/bin/sh -e

SETUPROOT=`readlink -f \`dirname $0\``
if [[ `basename $SETUPROOT` == "scripts" ]]
then
  SETUPROOT=`dirname $SETUPROOT`
fi
. $SETUPROOT/scripts/source_settings.sh $*

if (( $NO_START_DATE ))
then
  ENSEMBLE_PREFIX=${CASE_PREFIX}
else
  ENSEMBLE_PREFIX=${CASE_PREFIX}_${START_YEAR}${START_MONTH}${START_DAY}
fi

for MEMBER in `seq -w $MEMBER1 $MEMBERN`
do
  $SETUPROOT/../../tools/Noresm2nc4mpi/noresm2nc4mpi.${MACH}.sh $WORK/archive/$ENSEMBLE_PREFIX/${ENSEMBLE_PREFIX}_${MEMBERTAG}${MEMBER}
done

echo COMPLETE
