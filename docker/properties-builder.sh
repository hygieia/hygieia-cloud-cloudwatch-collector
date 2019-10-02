#!/bin/bash

if [ "$MONGO_PORT" != "" ]; then
	# Sample: MONGO_PORT=tcp://172.17.0.20:27017
	MONGODB_HOST=`echo $MONGO_PORT|sed 's;.*://\([^:]*\):\(.*\);\1;'`
	MONGODB_PORT=`echo $MONGO_PORT|sed 's;.*://\([^:]*\):\(.*\);\2;'`
else
	env
	echo "ERROR: MONGO_PORT not defined"
	exit 1
fi

echo "MONGODB_HOST: $MONGODB_HOST"
echo "MONGODB_PORT: $MONGODB_PORT"


#update local host to bridge ip if used for a URL
DOCKER_LOCALHOST=
echo $JENKINS_MASTER|egrep localhost >>/dev/null
if [ $? -ne 1 ]
then
	#this seems to give a access to the VM of the dockermachine
	#LOCALHOST=`ip route|egrep '^default via'|cut -f3 -d' '`
	#see http://superuser.com/questions/144453/virtualbox-guest-os-accessing-local-server-on-host-os
	DOCKER_LOCALHOST=10.0.2.2
	MAPPED_URL=`echo "$JENKINS_MASTER"|sed "s|localhost|$DOCKER_LOCALHOST|"`
	echo "Mapping localhost -> $MAPPED_URL"
	JENKINS_MASTER=$MAPPED_URL
fi

cat > $PROP_FILE <<EOF
#Database Name
dbname=${HYGIEIA_API_ENV_SPRING_DATA_MONGODB_DATABASE:-dashboarddb}
#Database HostName - default is localhost
dbhost=${MONGODB_HOST:-10.0.1.1}
#Database Port - default is 27017
dbport=${MONGODB_PORT:-27017}
#Database Username - default is blank
dbusername=${HYGIEIA_API_ENV_SPRING_DATA_MONGODB_USERNAME:-dashboarduser}
#Database Password - default is blank
dbpassword=${HYGIEIA_API_ENV_SPRING_DATA_MONGODB_PASSWORD:-dbpassword}
#Collector schedule (required)
cloudwatch.cron=${JENKINS_CRON:-0 0/5 * * * *}
cloudwatch.profile=${AWS_PROFILE}
cloudwatch.proxyHost=${AWS_PROXY_HOST}
cloudwatch.proxyPort=${AWS_PROXY_PORT}
cloudwatch.nonProxy=${AWS_NON_PROXY}
cloudwatch.region=${AWS_REGION:-eu-west-1}
# the collection period in minutes
cloudwatch.logAnalysisPeriod=${AWS_LOG_PERIOD:-1}

# now for the jobs.. you really need to sort this yourself
cloudwatch.jobs[0].name=YOUR_COLLECTION
cloudwatch.jobs[0].series[0].name=YOUR_SERIES
# for filter patterns see https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html
cloudwatch.jobs[0].series[0].filterPattern=YOUR_FILTER_PATTERN
cloudwatch.jobs[0].series[0].logGroupName=YOUR_LOG_GROUP_NAME
cloudwatch.jobs[0].series[0].logStreams[0]=YOUR_LOG_STREAM_NAME
EOF

echo "
===========================================
Properties file created `date`:  $PROP_FILE
Note: passwords & apiKey hidden
===========================================
`cat $PROP_FILE |egrep -vi 'password|apiKey'`
"

exit 0