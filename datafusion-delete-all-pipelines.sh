#!/bin/bash

project_id=$(echo `cat $1 | grep project-id | cut -d '=' -f2`)
location=$(echo `cat $1 | grep location | cut -d '=' -f2`)
instance_id=$(echo `cat $1 | grep instance-id | cut -d '=' -f2`)
cdap_endpoint=$(gcloud beta data-fusion instances describe --location=${location} --format="value(apiEndpoint)" ${instance_id})

access_token=$(gcloud auth print-access-token)
apps=$(curl -s --location --request GET ${cdap_endpoint}'/v3/namespaces/default/apps/' --header 'Authorization: Bearer '$access_token )

read -p "Are you sure want to delete all pipelines in your CDAP environment (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  #Please run sudo apt-get install jq if you don't have nc in your system
  for row in $(echo "${apps}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${row} | base64 --decode | jq -r ${1}

    }
  echo `curl -s --location --request DELETE ${cdap_endpoint}'/v3/namespaces/default/apps/'$(_jq '.name') --header 'Authorization: Bearer '$access_token` > /dev/null
  echo $(_jq '.name')' pipeline deleted.'
  done

else
  echo "Process cancelled."
  exit 0
fi
