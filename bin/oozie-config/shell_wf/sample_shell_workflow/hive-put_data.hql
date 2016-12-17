set mapred.job.queue.name=$queuename;
use ${dbname};
INSERT INTO ${dbname}.${final_table} VALUES('${res}');
