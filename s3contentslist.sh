#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -a BLOBNAME1 -b BLOBNAME2 -c BLOBNAME3"
   echo -e "\t name of the  BLOB a"
   echo -e "\t name of the  BLOB b"
   echo -e "\t name of the  BLOB c"
   echo -e "\t try $0 -a rawtools-nexusblobs -b ditools-live-nexusnpm-10252019 -c ditools-live-nexus-10232019"
   exit 1 # Exit script after printing help
}

while getopts "a:b:c:" opt
do
   case "$opt" in
      a ) BLOBNAME1="$OPTARG" ;;
      b ) BLOBNAME2="$OPTARG" ;;
      c ) BLOBNAME3="$OPTARG" ;;
      ?  ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$BLOBNAME1" ] || [ -z "$BLOBNAME2" ] || [ -z "$BLOBNAME3" ] 
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct

echo "----------BLOB1 DATA COUNT-----------------"

aws s3 ls s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//$BLOBNAME1/content/ | awk -v val1=$BLOBNAME1 '{print "s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//" val1  "/content/"$2}'

echo "Total directories is"
blob1dir=$(aws s3 ls s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//$BLOBNAME1/content/ | awk -v val1=$BLOBNAME1 '{print "s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//" val1  "/content/"$2}' | wc -l | tr -d '\040\011\012\015')
echo "${blob1dir}"
echo "----------BLOB2 DATA COUNT-----------------"

aws s3 ls s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//$BLOBNAME2/content/ | awk -v val2=$BLOBNAME2 '{print "s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//" val2  "/content/"$2}'
echo "Total directories is"
blob2dir=$(aws s3 ls s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//$BLOBNAME2/content/ | awk -v val2=$BLOBNAME2 '{print "s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//" val2  "/content/"$2}'| wc -l | tr -d '\040\011\012\015')
echo "${blob2dir}"
echo "----------BLOB3 DATA COUNT-----------------"

aws s3 ls s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//$BLOBNAME3/content/ | awk -v val3=$BLOBNAME3 '{print "s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//" val3  "/content/"$2}'
echo "Total directories is"
blob3dir=$(aws s3 ls s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//$BLOBNAME3/content/ | awk -v val3=$BLOBNAME3 '{print "s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//" val3  "/content/"$2}' | wc -l | tr -d '\040\011\012\015') 
echo ${blob3dir}


echo "------the required math is ----"
sumtotal=$(( $blob1dir + $blob2dir + $blob3dir ))
echo "The total directories for all the blobs to copy is ${sumtotal}"
echo "------the required number of c5.metal instances is----"
sum=$(($sumtotal/5))
echo "${sum}"
echo "-----Totalcost is--------"
spotprice=$(aws ec2 describe-spot-price-history --instance-types c5.metal --availability-zone us-east-1a --product-descriptions "Linux/UNIX" --start-time `date +"%Y-%m-%dT%T"` | jq '.SpotPriceHistory[].SpotPrice' | tr -d '"')
echo ${spotprice}
totalcost=`echo $spotprice \* $sum |bc`; echo $totalcost

echo "------the required number of c5.metal instances required only for biggest blob which is ditools-live-nexus-10232019----"
blobdirbig=$(aws s3 ls s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//ditools-live-nexus-10232019/content/ | awk '{print "s3://developer-data-toolstsyspropenterprise-us-east-1-tsys//ditools-live-nexus-10232019/content/"$2}' | wc -l | tr -d '\040\011\012\015')
blobdirbigsum=$(($blobdirbig/5))
echo ${blobdirbigsum}
echo "-----Totalcost for one blob is--------"
spotprice=$(aws ec2 describe-spot-price-history --instance-types c5.metal --availability-zone us-east-1a --product-descriptions "Linux/UNIX" --start-time `date +"%Y-%m-%dT%T"` | jq '.SpotPriceHistory[].SpotPrice' | tr -d '\040\011\012\015'|  tr -d '"')
echo ${spotprice}
totalcostforbigblob=`echo $spotprice \* $blobdirbigsum |bc`; echo $totalcostforbigblob

