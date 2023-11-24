
ENVIRON=$1
POP=$2
BUILD=$3
CREDENTIAL=$4

curl https://cdjenkins.npe.nettools.iad0.nskope.net/job/one_button_swg-api-service/buildWithParameters -H "Host: cdjenkins.npe.nettools.iad0.nskope.net" --user ${CREDENTIAL} --data RELEASE=swg-api-service-${BUILD} --data TICKET=ENG-341512 --data STORK_RELEASE=swg-api-service-${BUILD} --data STORK_ARTIFACTORY_CHANNEL=stork-develop --data STORK_COMPONENT_NAME=epdlp-dp --data POPS=${POP} --data CLUSTER_NAME=c1 --data DEPLOY_TYPE=selective-upgrade --data BYPASS_JIRA=NO --data ARTIFACTORY_PATH=artifactory-rd.netskope.io -k -sSL --fail
