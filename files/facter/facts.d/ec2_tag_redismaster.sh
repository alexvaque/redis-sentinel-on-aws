#!/bin/bash

REDISMASTERIP=$(/usr/bin/aws ec2 describe-instances \
--region us-east-1 \
--filters Name="tag-value",Values="redismaster" \
--query "Reservations[*].Instances[*].{Private:PrivateIpAddress}" \
--output text)

if [ -z "${REDISMASTERIP}" ]; then
  echo "ec2_tag_redismaster=0"
else
  echo "ec2_tag_redismaster=$REDISMASTERIP"
fi


