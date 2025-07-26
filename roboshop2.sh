    #!/bin/bash

    AMI=ami-0b4f379183e5706b9 #this keeps on changing
    SG_ID=sg-02691376fe9620bc7 #replace with your SG ID
    INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")


    for i in "${INSTANCES[@]}"
    do
        if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
        then
            INSTANCE_TYPE="t3.small"
        else
            INSTANCE_TYPE="t2.micro"
        fi

        IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids sg-02691376fe9620bc7 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
        echo "$i: $IP_ADDRESS"

        done
