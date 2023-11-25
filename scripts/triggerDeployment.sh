#!/bin/bash 

ENVIRON=$1
POP=$2
BUILD=$3
CREDENTIAL=$4

curl https://cdjenkins.npe.nettools.iad0.nskope.net/job/one_button_swg-api-service/buildWithParameters \
	-H 'Host: cdjenkins.npe.nettools.iad0.nskope.net' --user ${CREDENTIAL} --data RELEASE=swg-api-service-${BUILD} \
	-d TICKET=ENG-341512 \
	-d STORK_RELEASE=swg-api-service-${BUILD} \
	-d STORK_ARTIFACTORY_CHANNEL=stork-release \
	-d STORK_COMPONENT_NAME=swg-api-service \
	-d POPS=${POP} \
	-d CLUSTER_NAME=c1 \
	-d BYPASS_JIRA=YES \
	-d BYPASS_MONITORING_RESULT=YES \
	-d ARTIFACTORY_PATH=artifactory-rd.netskope.io -k -s -D - -o /dev/null > result_output

if cat result_output | grep -q "HTTP/2 201"
then
    echo "Deployment task was submitted successfully"
else
	echo "Failed to submit deployment task"
	exit 1
fi

QUEUE_URL="$(cat result_output | grep location | cut -d" " -f2 | sed s/.$//)api/json"
echo "Found Jenkins queue URL: ${QUEUE_URL}"
while true; do
	URL="$(curl -X GET --user ${CREDENTIAL} ${QUEUE_URL} -k -s | jq .executable.url | sed 's/\"//g')"
	echo "Job URL: ${URL}"
	if [ "${URL}" != "null" ]; then
		break
	fi
	sleep 15
done

JOB_URL="${URL}api/json"
while true; do
	RESULT=$(curl -X GET --user ${CREDENTIAL} ${JOB_URL}  -k -s | jq .result | sed 's/\"//g')
	echo "Job result: ${RESULT}"
	if [ "${RESULT}" != "null" ]; then
		break;
	fi
	sleep 30
done

echo "Final job result: ${RESULT}"
if [ "${RESULT}" == "SUCCESS" ]; then
	exit 0
else
	exit 1
fi
