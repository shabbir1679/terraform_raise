#!/bin/bash
groovy  tcs-pega.groovy > tcs-pega
cat tcs-pega | grep downloadUrl | awk '{print $2}' | tr -d '\"' |tr -d '\,' > urls
cp urls urls-restore
sed -i 's/restore-nexus.tools.tsys.aws/testnexus.tools.tsys.aws/g'  urls-restore

#for i in `cat urls`; do wget --no-check-certificate $i; myurl=$i; l=`echo ${myurl##*/}`; echo $l; done

for i in `cat urls`
do
  wget --no-check-certificate $i
done
for j in `cat urls-restore`
do
  myurl=$j
  l=`echo ${myurl##*/}`
  echo $l
  curl  -v -k  -u opsadmin:opsAdmin --upload-file $l $j
  rm -f $l
done
