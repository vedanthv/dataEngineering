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

**Problem with ```postgrescli```**








