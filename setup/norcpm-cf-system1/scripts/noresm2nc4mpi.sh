#!/bin/sh -e

SETUPROOT=`readlink -f \`dirname $0\``
if [[ `basename $SETUPROOT` == "scripts" ]]
then 
  SETUPROOT=`dirname $SETUPROOT`
fi 
. $SETUPROOT/scripts/source_settings.sh $*

### CUSTOMIZE BEGIN ###
NTASKS=64 ; NODES=4
ZIPRES=1 # 1=zip restart files
RMLOGS=1 # 1=remove log files 
COMPLEVEL=5
NCCOPY=$EBROOTNETCDF/bin/nccopy
NCDUMP=$EBROOTNETCDF/bin/ncdump
GZIP=`which gzip` 
TEMPDIR=/cluster/work/users/$USER/`basename $0 .sh`
CASEDIR=$1
### CUSTOMIZE END ###

# loop over members 
for MEMBER in `seq -w $MEMBER1 $MEMBERN`
do
  if (( $NO_START_DATE ))
  then
    ENSEMBLE_PREFIX=${CASE_PREFIX}
  else
    ENSEMBLE_PREFIX=${CASE_PREFIX}_${START_YEAR1}${START_MONTH1}${START_DAY1}
  fi
  CASE=${ENSEMBLE_PREFIX}_${MEMBERTAG}${MEMBER}
  CASEDIR=$WORK/archive/$ENSEMBLE_PREFIX/$CASE

# check input argument and print help blurb if check fails
if [[ ! $1 || $1 == "-h" || $1 == "--help" ]]
then
cat <<EOF
Usage: `basename $0` <path to case in archive directory> 

Example: `basename $0` /work/${USER}/archive/my-noresm-case 
  
Purpose: Converts NorESM output to compressed netcdf 4 format and gzips restarts   

Change history: 2021.04.06 port to BETZY
                2014.04.29 first version of `basename $0`
EOF
  exit 1
fi

# check that input folder exists
if [ ! -d $CASEDIR ] 
then 
  echo $CASEDIR not a directory! aborting... 
  exit 1 
fi 

# create temporary directory (if not existing) and cd 
mkdir -p $TEMPDIR
cd $TEMPDIR

# create convert exe 
if [ ! -e convert ]
then 
cat <<EOF> convert.c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mpi.h>
int main(int argc, char *argv[])
{
        int rank, result, i; char s[1024]; 
        MPI_Init(&argc, &argv);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        strcpy(s,"${TEMPDIR}/nccopy -k 4 -s -d ${COMPLEVEL} ");      
        for ( i = 0; i < argc-1; i++ ) {
          if (rank == i) {
            strcat(s,argv[i+1]);
            strcat(s," ");
            strcat(s,argv[i+1]);
            strcat(s,"_tmp ; mv ");
            strcat(s,argv[i+1]);
            strcat(s,"_tmp ");
            strcat(s,argv[i+1]); 
            strcat(s," ; chmod +r ");
            strcat(s,argv[i+1]); 
            printf("cpu=%3d: %s \n", rank+1, s);
            result = system(s);  
          }
        }
        MPI_Finalize();
}
EOF
mpicc -o convert convert.c
rm convert.c
fi

# create zip exe 
if [ ! -e zip ]
then
cat <<EOF> zip.c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mpi.h>
int main(int argc, char *argv[])
{
        int rank, result, i; char s[1024]; 
        MPI_Init(&argc, &argv);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        strcpy(s,"${TEMPDIR}/gzip ");      
        for ( i = 0; i < argc-1; i++ ) {
          if (rank == i) {
            strcat(s,argv[i+1]);
            printf("cpu=%3d: %s \n", rank+1, s);
            result = system(s);  
          }
        }
        MPI_Finalize();
}
EOF
mpicc -o zip zip.c
rm zip.c
fi

# copy other executables 
if [ ! -e nccopy ] ; then 
  cp $NCCOPY nccopy 
fi 
if [ ! -e ncdump ] ; then 
  cp $NCDUMP ncdump  
fi 
if [ ! -e gzip ] ; then 
  cp $GZIP gzip 
fi 

# create PBS script and submit  
LID="`date +%y%m%d-%H%M%S`"
cat <<EOF> `basename $0 .sh`_${LID}.slurm
#! /bin/sh -evx
#SBATCH --account=${ACCOUNT}
#SBATCH --job-name=convert_${CASE_PREFIX}
#SBATCH --time=${WALLTIME}
#SBATCH --ntasks=${NTASKS}
#SBATCH --nodes=${NODES}
#SBATCH --output=${TEMPDIR}/`basename $0 .sh`_${LID}.out

source /cluster/installations/lmod/lmod/init/sh
module --quiet restore system
module load StdEnv
module load netCDF/4.7.4-iompi-2020b
module load iompi/2020b

cd ${CASEDIR} 

# do history files 
ARGS=' ' 
for ncfile in \`find . -wholename '*/hist/*.nc' -print\`; do
  if [ \`${NCDUMP} -k \${ncfile} | grep 'netCDF-4' | wc -l\` -eq 0 ] ; then
    ARGS=\${ARGS}' '\${ncfile} 
    if [ \`echo \${ARGS} | wc -w\` -eq ${NTASKS} ] ; then 
      mpirun -n ${NTASKS} ${TEMPDIR}/convert \${ARGS}
      ARGS=' '
    fi 
  fi 
done 
if [ \`echo \${ARGS} | wc -w\` -gt 0 ] ; then 
  mpirun -n ${NTASKS} ${TEMPDIR}/convert \${ARGS}
fi

# do restart files 
if [ ${ZIPRES} == 1 ] ; then 
  ARGS=' '
  for ncfile in \`find . -wholename '*/rest/*.nc' -print\`; do
    ARGS=\${ARGS}' '\${ncfile} 
    if [ \`echo \${ARGS} | wc -w\` -eq ${NTASKS} ] ; then 
      mpirun -n ${NTASKS} ${TEMPDIR}/zip \${ARGS}
      ARGS=' '
    fi 
  done 
  if [ \`echo \${ARGS} | wc -w\` -gt 0 ] ; then 
    mpirun -n ${NTASKS} ${TEMPDIR}/zip \${ARGS}
  fi
fi 
for gzfile in \`find . -wholename '*/rest/*.gz' -print\`; do
  file \${gzfile} > /dev/null
done

# do log files 
if [ ${RMLOGS} -eq 1 ] ; then
  for logfile in \`find . -wholename '*/logs/*' -print\`; do
     rm -f \${logfile}
  done
fi

echo conversion COMPLETED 
EOF

RES=`sbatch \`basename $0 .sh\`_${LID}.slurm`
echo JOBID ${RES##* }
echo log out: ${TEMPDIR}/`basename $0 .sh`_${LID}.out 

# end loop over members
done
