### Week 1 Homework

SQL Queries Based Questions

1. **How mayn taxi trips were there on January 15th?**

```sql
SELECT COUNT(*)
FROM yellow_taxi_trips
WHERE tpep_pickup_datetime::date = '2021-01-15';
```

2. Find the largest tip for each day in january? On which day was the largest trip in Janauary?

```sql
SELECT date_trunc('day',tpep_pickup_datetime)
AS pickup_day,
MAX(tip_amount) AS max_tip
FROM yellow_taxi_trips
GROUP BY pickup_day
ORDER BY maxTip DESC
LIMIT 1;
```
3. What was the most popular destination for passengers picked up in central park on January 14?


