## Startup Instructions for Postgres and Docker Network

Just run 
```
docker system prune
```
to shut down all containers

When you want to start postgres and pgadmin run
```
docker compose up
```
from the ```week-1 directory``` to start the network.

Refer ```Dockerfile``` in the ```week-1``` directory to see how the network is built.

### Manual Start without Networks

```
docker run -it \
    -e POSTGRES_USER="root" \
    -e POSTGRES_PASSWORD="root" \
    -e POSTGRES_DB='ny_taxi' \
    --volume //DRIVELETTER/INSERTPATHHERE/data/ny_taxi_postgres_data:/var/lib/postgresql/data \
    -p 5432:5432 \
    --network=pg-network \
    --name pg-database-1 \
     postgres:13

docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -p 8080:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4

```
