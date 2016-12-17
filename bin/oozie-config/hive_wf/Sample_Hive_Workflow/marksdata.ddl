CREATE EXTERNAL TABLE marksdata (
Name String,Physics String,Maths String,Chemistry String
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/user/cloudera/pig_oozie_test/sem_marks_processed.txt'