#!/bin/bash

project_id=$(echo `cat $1 | grep project-id | cut -d '=' -f2`)
location=$(echo `cat $1 | grep location | cut -d '=' -f2`)
instance_id=$(echo `cat $1 | grep instance-id | cut -d '=' -f2`)
cdap_endpoint=$(gcloud beta data-fusion instances describe --location=${location} --format="value(apiEndpoint)" ${instance_id})

pipelines_list_path=$(echo `cat $1 | grep pipelines_list_path | cut -d '=' -f2`)
pipelines_sequence_name=$2
pipelines_sequence=$(echo `cat $pipelines_sequence_name`)
previous=$(echo `cat $pipelines_sequence_name | head -n 1`)

access_token=$(gcloud auth print-access-token)

read -p "Are you sure want to delete this sequence in your CDAP environment (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  #Please run sudo apt-get install jq if you don't have nc in your system
  for p in ${pipelines_sequence}; do
    echo `curl -s --location --request DELETE ${cdap_endpoint}'/v3/namespaces/default/apps/'${p} --header 'Authorization: Bearer '$access_token` > /dev/null
    echo ${p} pipeline deleted.
  done
else
  echo "Process cancelled."
  exit 0
fi
