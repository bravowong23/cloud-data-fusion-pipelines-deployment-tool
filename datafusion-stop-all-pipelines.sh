#!/bin/bash

project_id=$(echo `cat $1 | grep project-id | cut -d '=' -f2`)
location=$(echo `cat $1 | grep location | cut -d '=' -f2`)
instance_id=$(echo `cat $1 | grep instance-id | cut -d '=' -f2`)
cdap_endpoint=$(gcloud beta data-fusion instances describe --location=${location} --format="value(apiEndpoint)" ${instance_id})

access_token=$(gcloud auth print-access-token)
apps=$(curl -s --location --request GET ${cdap_endpoint}'/v3/namespaces/default/apps/' --header 'Authorization: Bearer '$access_token )

#Please run sudo apt-get install jq if you don't have nc in your system
for row in $(echo "${apps}" | jq -r '.[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${1}

  }
  status=$(curl -s --location --request GET ${cdap_endpoint}'/v3/namespaces/default/apps/'$(_jq '.name')'/workflows/DataPipelineWorkflow/status' --header 'Authorization: Bearer '$access_token)
  status=$(echo `echo ${status}  | cut -d '"' -f4` )
  if [ $status != 'STOPPED' ]; then
    echo `curl -s --location --request POST ${cdap_endpoint}'/v3/namespaces/default/apps/'$(_jq '.name')'/workflows/DataPipelineWorkflow/stop' --header 'Authorization: Bearer '$access_token` > /dev/null
    sleep 3
    status=$(curl -s --location --request GET ${cdap_endpoint}'/v3/namespaces/default/apps/'$(_jq '.name')'/workflows/DataPipelineWorkflow/status' --header 'Authorization: Bearer '$access_token)
    status=$(echo `echo ${status}  | cut -d '"' -f4` )
    echo $(_jq '.name')' '${status}'.'
  fi
done
