CREATE EXTERNAL TABLE storedoublecount (
count INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/cloudera/storedoublecount'
