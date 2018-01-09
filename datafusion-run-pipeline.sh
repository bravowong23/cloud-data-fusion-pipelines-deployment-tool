#!/bin/bash

project_id=$(echo `cat $1 | grep project-id | cut -d '=' -f2`)
location=$(echo `cat $1 | grep location | cut -d '=' -f2`)
instance_id=$(echo `cat $1 | grep instance-id | cut -d '=' -f2`)
cdap_endpoint=$(gcloud beta data-fusion instances describe --location=${location} --format="value(apiEndpoint)" ${instance_id})
access_token=$(gcloud auth print-access-token)

curl -s --location --request POST ${cdap_endpoint}'/v3/namespaces/default/apps/'$2'/workflows/DataPipelineWorkflow/start'  --header 'Authorization: Bearer '$access_token > /dev/null
