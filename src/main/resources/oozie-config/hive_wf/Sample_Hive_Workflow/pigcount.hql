set mapred.job.queue.name=$queuename
use ${dbname};
INSERT INTO ${dbname}.${TGT}
Select count(1) from ${dbname}.${SRC};