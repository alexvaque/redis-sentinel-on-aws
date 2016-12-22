#/bin/bash

IP=$(facter ipaddress)
COUNTER=0
ECINSTANCEID=$(facter ec2_instance_id)
ASGSLAVESNAME="stg-redis"
ASGMASTERNAME="stg-redismaster"

ROLE=$(/usr/bin/redis-cli -h $IP -p 6379 info | grep role | grep master | wc -l )
ASGMASTER=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASGMASTERNAME |grep AUTOSCALINGGROUPS | grep $ECINSTANCEID |wc -l)
echo "The server $IP has ROLE"$ROLE""


if [ $ROLE -eq 1 ]
then 
        echo "I am a MASTER, checking ..."
        for i in {1..5}
        do
           echo "======"
           /bin/sleep 5
           ROLE=$(/usr/bin/redis-cli -h $IP -p 6379 info | grep role | grep master |wc -l )
           ASGMASTER=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASGMASTERNAME |grep AUTOSCALINGGROUPS | grep $ECINSTANCEID |wc -l)
           echo "The server $IP has ROLE"$ROLE""
           echo "Welcome $i times"
           echo "ASGMASTER is"$ASGMASTER

                if [ $ROLE -eq 1 ] && [ $ASGMASTER -eq 0 ]; then
                    echo "MASTER: WARNING Conflict"
                    let COUNTER=COUNTER+1 
                    echo "MASTER: counter is" $COUNTER
                else
                    echo "MASTER: False Alarm"
		    echo "MASTER: all is OK"
                    exit -1
                fi

        done 

        if [ $COUNTER -eq 5 ]; then 
            echo "New Master" 
            aws autoscaling detach-instances --instance-ids $ECINSTANCEID --auto-scaling-group-name $ASGSLAVESNAME --should-decrement-desired-capacity
            /bin/sleep 15
            aws autoscaling attach-instances --instance-ids $ECINSTANCEID --auto-scaling-group-name $ASGMASTERNAME
        fi

else
        echo "I am SLAVE, checking ..."
        for i in {1..5}
        do
           echo "======"
           /bin/sleep 10
           ROLE=$(/usr/bin/redis-cli -h $IP -p 6379 info | grep role | grep master |wc -l )
           ASGMASTER=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASGMASTERNAME |grep INSTANCES | grep $ECINSTANCEID |wc -l)
           echo "SLAVE: The server $IP has ROLE"$ROLE""
           echo "SLAVE: Welcome $i times"
           echo "SLAVE: ASGMASTER is"$ASGMASTER

                if [ $ROLE -eq 0 ] && [ $ASGMASTER -eq 1 ]; then
                    echo "SLAVE: ERROR - what are you doing here ? removing Old Master "
                    let COUNTER=COUNTER+1
                    echo "SLAVE: The counter is "$COUNTER
                else
		    echo "SLAVE: False Alarm"
                    echo "SLAVE: all is OK"
                    exit -1
                fi

        done

        if [ $COUNTER -eq 5 ]; then 
            echo "Old Master" 
            # Option A
            # SSSshutdown -h 0
            # Option B
            #aws autoscaling detach-instances --instance-ids $ECINSTANCEID --auto-scaling-group-name $ASGMASTERNAME --should-decrement-desired-capacity
        fi

fi


