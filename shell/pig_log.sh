#!/bin/bash

set -xv



export wf_id=$1
export pig_actions=$2
export hdfs_path=$3
export wf_name=$4
export conn_str=$5
export OOZIE_URL=$6



for pig_action in $(echo $pig_actions | sed "s/,/ /g")
do
kinit -kt AppKeytab.keytab $conn_str || check_error "Failed During executing keytab"
filename=${wf_id}@${pig_action} || check_error "Failed During generating filename"



app_id=`oozie job -oozie ${OOZIE_URL} -info ${wf_id}@${pig_action} | head -3 | tail -1 | cut -d '/' -f 5`  || check_error "Cant Retrieve job id for pig action"

start_time=$(yarn logs -applicationId $app_id | grep -i -m1 -A1 startedAt | tail -n 1 |  awk -F  "\t" '{print $4}' ) || check_error "Cant Retrieve start time for pig action"

end_time=$(yarn logs -applicationId $app_id | tac | grep -i -m1 -B1 finishedAt | head -n 1 |  awk -F  "\t" '{print $5}') || check_error "Cant Retrieve end time for pig action"


tot_records=$(yarn logs -applicationId $app_id | grep stored | awk -F  " " '{print $3,$4,$7}'  ) || check_error "Cant Retrieve records for pig action"
file_details=$(yarn logs -applicationId $app_id | grep stored | rev | cut -d"/" -f1 | rev | cut -d '"' -f1) || check_error "Cant Retrieve records for pig action"
record=$(paste <(echo "$tot_records") <(echo "$file_details") --delimiters '') || check_error "Cant Retrieve records for pig action"



if [ -z "$record" ] || [ -z "$start_time" ] || [ -z "$end_time" ]; then
    status="failed"
else
    status="success"
fi

kinit -kt AppKeytab.keytab $conn_str || check_error "Failed During executing keytab"
echo $wf_name","$app_id","$pig_action","$start_time","$end_time","$status","$record","$wf_id | hadoop fs -appendToFile - ${hdfs_path} || check_error "Cant Write Entry for pig action"

done

check_error () {
error_msg=$1
echo $error_msg
exit 1
}