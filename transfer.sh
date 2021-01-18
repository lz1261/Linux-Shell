#!/bin/bash
arr=$1
cd /tmp
for number in ${arr[@]}; do
  echo "current Store Number: " $number

  # Download File from AWS S3
  AWSS3Route='s3://fr-production-bjn-teamworkretail/UQ/CN/'$number'/sales/'
  HostRoute=$number'/sales/'
  aws s3 cp $AWSS3Route $HostRoute --profile frcn-tp-prod --recursive
 
  # Upload File to Tencent COS
  TencentCOSRoute='UQ/CN/'$number'/sales'      
  coscmd -c '/var/lib/jenkins/tabletpos-s3-cos-copy.conf'  upload -r $HostRoute $TencentCOSRoute
 
  # Get File Date
  for fileName in $(ls $HostRoute); do

    AWSS3FileRoute=$AWSS3Route$fileName
    AWSS3FileDate=`aws s3 ls $AWSS3FileRoute --profile frcn-tp-prod | awk '{print $1}' | sed 's/-//g'`
    
    AWSS3BackupRoute='s3://fr-production-bjn-teamworkretail/UQ/CN/BKUP/0260/'$AWSS3FileDate'/'
    aws s3 mv $AWSS3FileRoute $AWSS3BackupRoute --profile frcn-tp-prod
 
  done

  rm -rf $number  

done
