For local setup:
  1. install python version3.
       refer link for installing python 3 on linux system--> https://computingforgeeks.com/how-to-install-python-on-ubuntu-linux-system/
  2. install pip3
      ex. apt install python3-pip
      for version check -> pip3 --version
      refer link: https://digit-discuss.atlassian.net/wiki/spaces/DD/pages/1865777171/DIGIT+Internal+Datamart+deployment+steps 
  3. install required libraries like requests, pandas, psycopg2-binary etc. mentiond in requirnments.txt file using pip command.
      ex. pip3 install requests
  4. To run the application locally, we have to load the variable from the .env file to environment so that script can use to do so run below command (NOTE: this to run locally, when running on the pod these variables will be loaded from help)
  ``while read LINE; do export "$LINE"; done < ./.env``
  4. for running app.py use command 
      ex. python3 app.py
    
    
