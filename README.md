## Data Engineering Zoomcamp By datatalks.club

### Week 1 : Prerequisites and Setup

#### 1.2.1 Introduction To Docker
Docker is a containerization software that allows us to isolate software in a similar way to virtual machines but in a much leaner way.

A Docker image is a snapshot of a container that we can define to run our software, or in this case our data pipelines. By exporting our Docker images to Cloud providers such as Amazon Web Services or Google Cloud Platform we can run our containers there.

Docker provides the following advantages:

- Reproducibility
- Local experimentation
- Integration tests (CI/CD)
- Running pipelines on the cloud (AWS Batch, Kubernetes jobs)
- Spark (analytics engine for large-scale data processing)
- Serverless (AWS Lambda, Google functions)
- Docker containers are stateless: any changes done inside a container will NOT be saved when the container is killed and started again. 

This is an advantage because it allows us to restore any container to its initial state in a reproducible manner, but you will have to store data elsewhere if you need to do so; a common way to do so is with volumes.

**Installing Docker**
Watch any video online and install Docker for Ubuntu

**Checking if Docker is Installed Correctly**
```
docker run hello-world
```

**Run linux commands in docker bash**
```
docker run -it ubuntu bash
```
Here we can run any command like ```ls```

**Running Python in Docker**
```
docker run -it python:3.9
```

**Installing Pandas**

1. Defining the entry point as bash
```
docker run -it --entrypoint=bash python:3.9
```
Run the following
```
pip install pandas
```
Pandas is installed only in sppecific docker container.
Note : ctrl + d to exit python interactive bash

**Problem** : When we exit bash and run ```import pandas``` nothing happens and pandas is gone as the python:3.9 docker container doesnt save the state

To solve this problem:

- Create a Dockerfile[its in week-1 folder]
- ```FROM python:3.9``` selects image as python 3.9
- ```RUN pip install pandas``` runs the command
- ```ENTRYPOINT bash``` selects the entry point as bash

**Now use ```docker build -t test:pandas .  ```**

- docker build helps build the image
- -t is used tospecify tags
- test is the name of the image
- pandas is the version
- . tells docker to go to the folder which has Dockerfile, navigate its path and execute it

Now if we do ```docker run -it test:pandas``` then we can use ```import pandas```

#### Simple Pipeline 

Add these two to Dockerfile

```
WORKDIR /app
COPY pipelin.py pipeline.py
```

- WORKDIR specifies where the pipeline.py file must be put into
- COPY specifies the source path and the destination path inside app dir.

Now run ```docker build -t test:pandas .``` and ```docker run -it test:pandas```

The working directory would be ```/app``` now!

From here we can run ```python pileine.py``` and job finished is printer on screen.

##### Task : Printing the records of a specific day

**pipeline.py**
```
import pandas as pd 

# fancy pandas stuff
print(sys.argv)

day = sys.argv[1]

print(f"job finished successfully for the day = f{day}")
```

**dockerfile**
```
FROM python:3.9

RUN pip install pandas

WORKDIR /app
COPY pipeline.py pipeline.py

ENTRYPOINT ["python","pipeline.py"]
```

Now run ```docker build -t test:pandas .```

Then finally execute like this 
```
docker run -it test:pandas 2021-02-15
```

Output would be:

```
job finished successfully for the day = f2021-02-15
```

### Postgres and Docker

**1.2.2 Ingesting NY Taxi Data to Postgres**

To download the data that we are going to use(NYC Taxi Cab Dataset) us the below command:

```
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/yellow_tripdata_2021-01.csv.gz
```

**Running Postgres from Docker**

```
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB='ny_taxi' \
    --volume //DRIVELETTER/INSERTPATHHERE/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
     postgres:13
```

**Meaning of the code :** 
```
-e -> a tag that allows us to config stuff

--volume -> the dataset path that needs to be inserted in the postgres db

-p -> port on which postgres should run

postgres:13 -> version of postgres
```

At this point a directory ny_taxi_postgres_data must be created. **Do not worry if its empty, as long as the command runs successfully, everything is fine**

Now at this point we have successfully connected postgres image with docker!

There must be a way to query the database in postgres right? Here's where ```pgcli``` comes into the picture giving us ability to write sql commands in the cli.

**Working with pgcli**

- Installing ```pgcli```
Use the following command:
```
pip install pgcli
```

- Use ```pgcli``` to connect to postgres
```
pgcli -h localhost -p 5432 -u root -d ny_taxi
```

- Some commands you can test to check whether cli works or not
    - ```\dt``` -> should show the tables list
    - ```SELECT COUNT(1) FROM nyc_taxi_data```

**Problem with ```postgrescli```**

The major problem with pgcli is that its just a command line interface for executing simple queries in test, but it would be great if we could have a clean GUI right? Here is where ```pgadmin``` comes into play.

#### pgadmin setup and configuration

pgAdmin provides a clear GUI for postgres data querying.

**installing pgAdmin**

Let's install pgadmin by creating the docker image for it.

```
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  dpage/pgadmin4
```

Here we provide an email and password for access creds and specify the port.

**Is your pgadmin dashboard loading slowly?**

If this is the case, change ```dpage/pgadmin4``` to ```dpage/pgadmin3``` and it loads faster.

**Creating Server on pgAdmin**

When we try to create server as shown in the video, we see that there is an error because our pgAdmin exists in one container and postgres is in another container. There is no connection between them. 

Using Docker Networks, we can put two or more images in one Docker Container and run everything smoothly. Let's do that now.

1. **Creating a docker network**

```docker network create pg-network```

2. Adding postgres to our network

```
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB='ny_taxi' \
    --volume //DRIVELETTER/INSERTPATHHERE/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pgnetwork \
    --name pg-database \
     postgres:13
     
```

3. Adding pgAdmin to out network

```
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  --network=pg-network \
  --name pgadmin-2 \
  dpage/pgadmin4
```

Now everythin should be set and you should be able to create server in pgAdmin.

#### Data Ingestion with Docker Backend

Let's now convert our ipynb file to a neat python pipeline.

First go to pgAdmin dash board and drop the existing tables.

```DROP TABLE nyc_cab_data;```

**ingest-data.py**

1. Importing Dependencies

```
import os
import argparse

from time import time

import pandas as pd
from sqlalchemy import create_engine

```

```argparse``` is used to parse the arguments from the command line.
```

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password', required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host for postgres')
    parser.add_argument('--port', required=True, help='port for postgres')
    parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--url', required=True, help='url of the csv file')

    args = parser.parse_args()

    main(args)
```

In the above code we specify the arguments that the user can enter. Then we call the ```parser.parse_args()``` to collect all the args in one array and then pass them to the ```main``` function as an array.

Check the ```ingest-data.py``` script to know more about main function.

Now we must get back the dataset on pgAdmin Dashboard.

**Dockerizing the Ingestion Script**




















export GOOGLE_APPLICATION_CREDENTIALS="</home/vedanth/dataEngineering/week-1/premium-bloom-368403-091ed03452fd.json"
