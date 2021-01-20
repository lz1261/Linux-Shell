#!/bin/bash
numberArr=$1

cd /tmp

# AWS Information
AWSProfile='frcn-tp-prod'
AWSS3FileRoutePrefix='s3://test-production-bjn-teamworkretail'
AWSS3FileRouteMidfix='/UQ/CN/'
AWSS3FileRouteSuffix='/sales/'

# Tencent Information
TencentProfile='/var/lib/jenkins/tabletpos-s3-cos-copy.conf'
TencentCOSFileRoutePrefix='UQ/CN/'
TencentCOSFileRouteSuffix='/sales'

for number in ${numberArr[@]}; do
  echo "current Store Number: " $number

  # Download File from AWS S3
  AWSS3Route=$AWSS3FileRoutePrefix$AWSS3FileRouteMidfix$number$AWSS3FileRouteSuffix
  HostRoute=$number$AWSS3FileRouteSuffix
  aws s3 cp $AWSS3Route $HostRoute --profile $AWSProfile --recursive
 
  # Upload File to Tencent COS
  TencentCOSRoute=$TencentCOSFileRoutePrefix$number$TencentCOSFileRouteSuffix     
  coscmd -c $TencentProfile upload -r $HostRoute $TencentCOSRoute
 
  # Remove HostFile
  rm -rf $number 

  # Backup File

  currentDate=$(date -d now +%Y%m%d)
  yesterdayDate=$(date -d yesterday +"%Y%m%d")

  arrayDate=($currentDate $yesterdayDate)
  for date in ${arrayDate[@]};do
    echo "current date" $date
    include='*.*.'$date'.*.*.*'
    echo "include" \"$include\"
    AWSS3BackupRoute=$AWSS3FileRoutePrefix$AWSS3FileRouteMidfix'BKUP/'$number'/'$date'/'
    aws s3 mv $AWSS3Route $AWSS3BackupRoute --profile $AWSProfile --recursive --exclude "*" --include \"$include\"
  done
  

done
