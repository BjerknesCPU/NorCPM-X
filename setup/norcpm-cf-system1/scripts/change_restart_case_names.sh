#!/bin/sh -evx

RESBASEOLD=/cluster/work/users/ingo/archive/NorESM1-ME_historicalExt_noAssim_19700101
RESBASENEW=/cluster/work/users/ingo/restarts/NorESM1-ME_historicalExt_noAssim 
STARTDATE=1980-01-01-00000
MEMBER1=31
MEMBERN=60

for MEMBER in `seq -w $MEMBER1 $MEMBERN`
do 
  PREFIXOLD=`basename $RESBASEOLD`
  PREFIXNEW=`basename $RESBASENEW`
  RESDIROLD=$RESBASEOLD/${PREFIXOLD}_mem$MEMBER/rest/$STARTDATE
  RESDIRNEW=$RESBASENEW/${PREFIXNEW}_mem$MEMBER/rest/$STARTDATE
  mkdir -p $RESDIRNEW
  cd $RESDIRNEW
  for FILEOLD in `ls $RESDIROLD`
  do 
    FILENEW=`echo $FILEOLD | sed "s/${PREFIXOLD}/${PREFIXNEW}/"`
    cp -fv $RESDIROLD/$FILEOLD $FILENEW
    if [[ ${FILENEW} == *.cpl.r.* ]]
    then 
      ncks -h -O -v seq_infodata_case_name $FILENEW tmp.nc 
      ncdump tmp.nc | sed "s/${PREFIXOLD}/${PREFIXNEW}/g" > tmp.cdl
      ncgen -o tmp.nc tmp.cdl 
      ncks -A -o $FILENEW tmp.nc
      rm tmp.nc tmp.cdl  
    fi
    if [[ ${FILENEW} == *.cam2.r.* ]]
    then 
      ncatted -h -a caseid,global,o,c,${PREFIXNEW}_mem$MEMBER $FILENEW
      ncks -h -O -v nfpath,nhfil,cpath $FILENEW tmp.nc 
      ncdump tmp.nc | sed "s/${PREFIXOLD}/${PREFIXNEW}/g" > tmp.cdl
      ncgen -o tmp.nc tmp.cdl 
      ncks -A -o $FILENEW tmp.nc
      rm tmp.nc tmp.cdl  
    fi
    if [[ ${FILENEW} == *.clm2.r.* ]]
    then
      ncatted -h -a caseid,global,o,c,${PREFIXNEW}_mem$MEMBER $FILENEW
      ncatted -h -a caseid,global,o,c,${PREFIXNEW}_mem$MEMBER $FILENEW
      ncks -h -O -v locfnh,locfnhr $FILENEW tmp.nc 
      ncdump tmp.nc | sed "s/${PREFIXOLD}/${PREFIXNEW}/g" > tmp.cdl
      ncgen -o tmp.nc tmp.cdl 
      ncks -A -o $FILENEW tmp.nc
      rm tmp.nc tmp.cdl  
      
    fi 
    if [[ ${FILENEW} == rpoint* ]]
    then 
      sed -i -e "s/${PREFIXOLD}/${PREFIXNEW}/g" $FILENEW
    fi
  done 
done 
echo COMPLETE
