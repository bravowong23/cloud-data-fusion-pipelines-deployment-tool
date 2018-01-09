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

#echo ${cdap_endpoint}

read -p "Are you sure want to deploy this sequence in your CDAP environment (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  #Please run sudo apt-get install jq if you don't have nc in your system
  echo `curl -s --location --request POST ${cdap_endpoint}'/v3/namespaces/default/apps/'${previous}'/schedules/dataPipelineSchedule/disable' --header 'Authorization: Bearer '$access_token` > /dev/null
  echo ${previous} schedule disabled.
  for p in ${pipelines_sequence}; do
    echo "Deploying Sequence "${pipelines_sequence_name}

    #Stop the pipeline to be deployed
    echo `curl -s --location --request POST ${cdap_endpoint}'/v3/namespaces/default/apps/'${p}'/workflows/DataPipelineWorkflow/stop' --header 'Authorization: Bearer '$access_token` > /dev/null
    sleep 1

    #Delete the pipeline from CDAP
    echo `curl -s --location --request DELETE ${cdap_endpoint}'/v3/namespaces/default/apps/'${p} --header 'Authorization: Bearer '$access_token` > /dev/null
    sleep 1
    #Deploy the pipeline
    echo `curl -s -X PUT ${cdap_endpoint}'/v3/namespaces/default/apps/'${p} -d '@'${pipelines_list_path}'/'${p}'-cdap-data-pipeline.json' --header 'Authorization: Bearer '${access_token}` > /dev/null
    if [ $p != $previous ]; then
      echo 'Add '${p}' to sequence.'
      echo `curl -s --location --request POST ${cdap_endpoint}'/v3/namespaces/default/apps/'${p}'/schedules/dataPipelineSchedule/update' \
    --header 'Authorization: Bearer '${access_token} \
    --header 'Content-Type: application/json' \
    --data-raw '{
    "trigger": {
      "programId": {
        "application": "'${previous}'",
        "version": "-SNAPSHOT",
        "type": "Workflow",
        "program": "DataPipelineWorkflow",
        "namespace": "default",
        "entity": "PROGRAM"
      },
      "programStatuses": [
        "COMPLETED"
      ],
      "type": "PROGRAM_STATUS"
    }
    }'` > /dev/null
      echo `curl -s --location --request POST ${cdap_endpoint}'/v3/namespaces/default/apps/'${p}'/schedules/dataPipelineSchedule/enable' \
    --header 'Authorization: Bearer '${access_token} \
    --data-raw ''` > /dev/null
    previous=${p}
    fi

    echo ${p} ' deployed.'
  done
  #echo `curl -s --location --request POST ${cdap_endpoint}'/v3/namespaces/default/apps/'${head}'/schedules/dataPipelineSchedule/enable' --header 'Authorization: Bearer '$access_token` > /dev/null
  #echo ${head} schedule enabled.
else
  echo "Process cancelled."
  exit 0
fi
