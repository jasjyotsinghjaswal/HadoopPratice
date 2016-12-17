set mapreduce.job.queuename '$pig_queue';

MARKS_SET = LOAD '/user/cloudera/pig_oozie_test/sem_marks.txt' USING PigStorage(',') AS (Name:chararray,Semester:int,Physics:int,Maths:int,Chemistry:int);
MARKS_SET_ON_NAME = GROUP MARKS_SET BY Name;
MARKS_AVG = FOREACH MARKS_SET_ON_NAME GENERATE group,(SUM(MARKS_SET.Physics)/3),(SUM(MARKS_SET.Maths)/3),(SUM(MARKS_SET.Chemistry)/3);
STORE MARKS_AVG INTO  '/user/cloudera/pig_oozie_test/sem_marks_processed.txt' USING PigStorage('\t');
