#!/bin/bash
arr=$1
cd /tmp
for number in ${arr[@]}; do
  echo "current Store Number: " $number
  
  # s3://fr-production-bjn-teamworkretail/UQ/CN/{4位门店号}/sales/
  AWSS3Route='s3://test-production-bjn-teamworkretail/UQ/CN/'$number'/sales/'
  HostRoute=$number'/sales/'
  aws s3 cp $AWSS3Route $HostRoute --profile frcn-tp-prod --recursive
 
  TencentCOSRoute='UQ/CN/'$number'/sales' 
  # coscmd config -a “”  -s “” -b “” -r “”      
  coscmd -c '/var/lib/jenkins/tabletpos-s3-cos-copy.conf'  upload -r $HostRoute $TencentCOSRoute
 
  # S3 All fileName
  for fileName in $(ls $HostRoute); do

    AWSS3FileRoute=$AWSS3Route$fileName
    AWSS3FileDate=`aws s3 ls $AWSS3FileRoute --profile frcn-tp-prod | awk '{print $1}' | sed 's/-//g'`
    
    # s3://fr-production-bjn-teamworkretail/UQ/CN/BKUP/0260/{YYYYMMDD}/
    AWSS3BackupRoute='s3://test-production-bjn-teamworkretail/UQ/CN/BKUP/0260/'$AWSS3FileDate'/'
    aws s3 mv $AWSS3FileRoute $AWSS3BackupRoute --profile frcn-tp-prod
 
  done

  rm -rf $number  

done
