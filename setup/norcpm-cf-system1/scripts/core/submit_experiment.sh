#!/bin/sh -e

SETUPROOT=`readlink -f \`dirname $0\``
if [[ `basename $SETUPROOT` == "core" || `basename $SETUPROOT` == "util" ]]
then
  SETUPROOT=`dirname \`dirname $SETUPROOT\``
fi
. $SETUPROOT/scripts/core/source_settings.sh $*

echo + DETERMINE PES NUMBER FOR ENSEMBLE 
START_DATE_SHORT1=$START_YEAR1$START_MONTH1$START_DAY1
CASE1=${EXPERIMENT}_${START_DATE_SHORT1}_mem$MEMBER1
RELPATH1=$EXPERIMENT/${EXPERIMENT}_$START_DATE_SHORT1/$CASE1
CASEROOT1=$CASESROOT/$RELPATH1
MPPWIDTHOLD=`grep "\-ntasks" $CASEROOT1/${CASE1}.${MACH}.run | cut -d"=" -f2 | cut -d":" -f1`
MPPWIDTHNEW=`expr $MPPWIDTHOLD \* $ENSSIZE` 
NODESNEW=`expr $MPPWIDTHNEW / $TASKS_PER_NODE` 
if [ $NODESNEW -lt $MIN_NODES ] 
then 
  NODESNEW=$MIN_NODES
elif [ `expr $NODESNEW \* $TASKS_PER_NODE` -lt $MPPWIDTHNEW ] 
then
  NODESNEW=`expr $NODESNEW + 1` 
fi

echo + WRITE ENSEMBLE JOB-SCRIPT 
JOB_SCRIPT=$CASEROOT1/${EXPERIMENT}.runens
cat <<EOF> $JOB_SCRIPT
#!/bin/sh -e
#SBATCH --account=${ACCOUNT}
#SBATCH --job-name=${EXPERIMENT}
#SBATCH --time=${WALLTIME}
#SBATCH --nodes=${NODESNEW}
#SBATCH --ntasks=${MPPWIDTHNEW}
#SBATCH --output=$CASEROOT1/${EXPERIMENT}.log_%j

SETUPROOT=${SETUPROOT}
source ${SETUPROOT}/scripts/core/run_experiment.sh $* 
EOF

echo + SUBMIT JOB
JOBID=`sbatch $JOB_SCRIPT | awk '{print $4}'`
echo ++ log written to $CASEROOT1/${EXPERIMENT}.log_$JOBID
