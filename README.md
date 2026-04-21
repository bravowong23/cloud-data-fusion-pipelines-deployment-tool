To run the provided shell scripts, you need to have below anyone of below environment:

  Linux or MAC OS
  
  Cloudshell on GCP Console
  
To run the provided python script, you need to have below version installed:

  Python3
  
Windows user may need to run this on Windows Subsystem for Linux (WSL) but this hasn’t been tested

Google Cloud SDK for authentication
  
  https://cloud.google.com/sdk/docs/install
  
Git for cloning your code from Google Cloud Source Repositories
You also need administrative access to Data Fusion environment
*we observed scripts run on different OS environment may have behavioral differences in result, MAC OS is the most reliable one

To export all pipelines from Google Cloud Data Fusion / CDAP, refresence these steps:

  Step 1: login to project from cli.
  
    Cmd: gcloud auth login
    
  Step 2: select project
  
    Cmd: gcloud config set project [your-gcp-project-code]
    
  Step 3: go to your script folder, export all pipelines to specified path
  
    Cmd: python3 datafusion-export-pipelines.py connection.conf 
    
  Step 4: deploy all pipelines and sequences to production environment
  
    Cmd: ./datafusion-deploy-a-sequence.sh ../connection.conf ../pipelines.list
    
  Step 5: Check your deployment result in production environment
