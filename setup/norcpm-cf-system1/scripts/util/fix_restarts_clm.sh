#! /bin/sh -e
#SBATCH --account=nn9039k
#SBATCH --job-name=fix_restarts_clm
#SBATCH --time=24:00:00
#SBATCH --ntasks=8
#SBATCH --mem=32GB
#SBATCH --qos=preproc
#SBATCH --output=clone_restarts_clm.out

source /cluster/installations/lmod/lmod/init/sh
module --quiet restore system
module load StdEnv
module load netCDF/4.7.4-iompi-2020a

ARCHIVE_DIR=$1 
if [[ ! -d $ARCHIVE_DIR ]]
then 
  echo "USAGE: $0 <archive path of case>"
  exit
fi 
cd $ARCHIVE_DIR

fix_restart () {
  PREFIX=`basename $FNAME .nc`
  nccopy -6 $FNAME ${PREFIX}.nc3 
  ncdump ${PREFIX}.nc3 | sed -e '/ntapes = .*/a\        string_length = 64 ;' -e '/ntapes = .*/a\        levgrnd = 15 ;' | ncgen -o $FNAME 
}

PROC=1 
for FNAME in `find . -name "*.clm2.r.*.nc"`
do
  echo $FNAME
  fix_restart & 
  if [ $PROC -lt 8 ]
  then 
    PROC=$((PROC+1))
  else 
    PROC=1
    wait
  fi   
done
wait
echo COMPLETE
