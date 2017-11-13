#!/bin/sh

set -xv

####1.Cut fields from lookup file & generate Module Name,Workflow name & Type.Extract All Runnning Jobs & All Non-Running Jobs only for today####
DATE=`date +%Y-%m-%d`

edgenode_dir=$1
export edgenode_path=${edgenode_dir}/report_for_status_check
export inbound_path=${edgenode_path}/inbound/entity
export lookup_file_name=${edgenode_path}/lookup/lookup_for_status_entity
export success_killed_all_jobs=${inbound_path}/success_killed_all_jobs.dat
export running_all_jobs=${inbound_path}/running_all_jobs.dat
export suspended_all_jobs=${inbound_path}/suspended_all_jobs.dat 
export succ_kill_recent_job=${inbound_path}/success_killed_all_jobs_only_for_today.dat
export final_result=${inbound_path}/final_result.dat
export Failed_all_jobs=${inbound_path}/Failed_all_jobs.dat
export Failed_recent_job=${inbound_path}/Failed_recent_job.dat
export prep_all_jobs=${inbound_path}/prep_all_jobs.dat
export sorted_final_output=${inbound_path}/sorted_final_output.dat
export OOZIE_URL=$3
export USER_ID=$4
echo "$lookup_file_name"
rm ${success_killed_all_jobs}
rm ${running_all_jobs}
#rm ${suspended_prep_all_jobs}
rm ${suspended_all_jobs}
rm ${succ_kill_recent_job}
rm ${final_result}
rm ${Failed_all_jobs}
rm ${Failed_recent_job}
rm ${prep_all_jobs}
rm ${sorted_final_output}

echo "Removed all the directorys from Inbound-----------------------------------------------------------------------------------------------------------------------------------"

while read -r line
do  
echo "record is ${line}"
export MODULE_NAME=$(echo "$line" | cut -d ',' -f1)
export WF_NM=$(echo "$line" | cut -d ',' -f2)
export TYPE=$(echo "$line" | cut -d ',' -f3 )

MSG=$(oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=RUNNING" | head -n 1)
if [ "$MSG" != "No Jobs match your criteria!" ];
then
oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=RUNNING" | grep -v '^-' | grep -v '^Job ID' | awk '{ print $2,$5,$6,$7,$8,$9,$10,$1}'| awk -F "$WF_NM" '{ print $2}' | awk '{ print $6,$2,$3,$4,"XXXX-XX-XX XX:XX GMT",$1}'| awk -v WF_NM=$WF_NM '{print WF_NM," ",$0}'| awk -v MODULE_NAME=$MODULE_NAME '{print MODULE_NAME," ",$0}' |awk -v OFS="," '$1=$1'|sed -e 's/,GMT/ GMT/g' -e 's/,/ /4' -e 's/,/ /5' >> ${running_all_jobs}
fi

MSG=$(oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=SUCCEEDED;status=KILLED" | head -n 1)
if [ "$MSG" != "No Jobs match your criteria!" ];
then
oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=SUCCEEDED;status=KILLED" | grep -v '^-' | grep -v '^Job ID'| awk '{ print $2,$5,$6,$7,$8,$9,$10,$1}'| awk -F "$WF_NM" '{print $2}' | awk '{ print $8,$2,$3,$4,$5,$6,$7,$9,$10,$1}'|  awk -v WF_NM=$WF_NM '{print WF_NM," ",$0}'| awk -v MODULE_NAME=$MODULE_NAME '{print MODULE_NAME," ",$0}'|awk -v OFS="," '$1=$1'|sed -e 's/,GMT/ GMT/g' -e 's/,/ /4' -e 's/,/ /5' >> ${success_killed_all_jobs}

cat ${success_killed_all_jobs}| grep $DATE >> ${succ_kill_recent_job}
fi

MSG=$(oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=FAILED"  | head -n 1)
if [ "$MSG" != "No Jobs match your criteria!" ];
then
oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=FAILED" | grep -v '^-' | grep -v '^Job ID'| awk '{ print $2,$5,$6,$7,$8,$9,$10,$1}'| awk -F "$WF_NM" '{ print $2}' | awk '{print $6,$2,$3,$4,"XXXX-XX-XX XX:XX GMT",$1}'|  awk -v WF_NM=$WF_NM '{print WF_NM," ",$0}'| awk -v MODULE_NAME=$MODULE_NAME '{print MODULE_NAME," ",$0}' |awk -v OFS="," '$1=$1'|sed -e 's/,GMT/ GMT/g' -e 's/,/ /4' -e 's/,/ /5' >> ${Failed_all_jobs}

cat ${Failed_all_jobs}| grep $DATE >> ${Failed_recent_job}
fi

MSG=$(oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=SUSPENDED"  | head -n 1)
if [ "$MSG" != "No Jobs match your criteria!" ];
then
oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=SUSPENDED" | grep -v '^-' | grep -v '^Job ID'| awk '{ print $2,$5,$6,$7,$8,$9,$10,$1}'| awk -F "$WF_NM" '{ print $2}' | awk '{print $6,$2,$3,$4,"XXXX-XX-XX XX:XX GMT",$1}'|  awk -v WF_NM=$WF_NM '{print WF_NM," ",$0}'| awk -v MODULE_NAME=$MODULE_NAME '{print MODULE_NAME," ",$0}' |awk -v OFS="," '$1=$1'|sed -e 's/,GMT/ GMT/g' -e 's/,/ /4' -e 's/,/ /5' >> ${suspended_all_jobs}
fi

MSG=$(oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=PREP"  | head -n 1)
if [ "$MSG" != "No Jobs match your criteria!" ];
then
oozie jobs -oozie ${OOZIE_URL}  -len 200000  -filter "user=${USER_ID};name=$WF_NM;status=PREP" | grep -v '^-' | grep -v '^Job ID'| awk '{ print $2,$5,$6,$7,$8,$9,$10,$1}'| awk -F "$WF_NM" '{ print $2}' | awk '{print $4,"XXXX-XX-XX XX:XX GMT","XXXX-XX-XX XX:XX GMT",$1}'|  awk -v WF_NM=$WF_NM '{print WF_NM," ",$0}'| awk -v MODULE_NAME=$MODULE_NAME '{print MODULE_NAME," ",$0}' |awk -v OFS="," '$1=$1'|sed -e 's/,GMT/ GMT/g' -e 's/,/ /4' -e 's/,/ /5' >> ${prep_all_jobs}
fi

cat ${running_all_jobs} ${succ_kill_recent_job} ${Failed_recent_job} ${suspended_all_jobs} ${prep_all_jobs} > ${final_result}

cat ${final_result} | sort -u > ${sorted_final_output}

done<${lookup_file_name}

################ Format data in proper format for reporting purpose #################
gawk -v curr_dt="$DATE" 'BEGIN{
FS=","
print "<html><head> <style> .SUCCEEDED {     background-color: #33ff82; } .KILLED {     background-color: #F08080; } .RUNNING {     background-color: yellow; } .FAILED {     background-color: #ff333c; } .SUSPENDED { background-color: #808000; } .PREP { background-color: #FFFFFF; }</style> </head> <body><p style='color:black'>Hi Team,</p><p style='color:black'>Please find below status for oozie jobs for "
print curr_dt
print "</p><table border=1 cellspacing=0 cellpadding=3>"
print "<tr>"
 print "<th style='text-align:center';'color:white';'background-color:DarkBlue'>MODULE_NAME</td>";
 print "<th style='text-align:center';'color:white';'background-color:DarkBlue'>WORKFLOW_NAME</td>";
 print "<th style='text-align:center';'color:white';'background-color:DarkBlue'>OOZIE_JOB_ID</td>";
 print "<th style='text-align:center';'color:white';'background-color:DarkBlue'>START_TIME</td>";
 print "<th style='text-align:center';'color:white';'background-color:DarkBlue'>END_TIME</td>";
 print "<th style='text-align:center';'color:white';'background-color:DarkBlue'>STATUS</td>";
 print "</tr>"
}
 {
print "<tr>"
for(i=1;i<=NF;i++)
{
printf "<td class='%s'",$6
printf " style='text-align:center';'color:DarkBlue'>%s</td>",$i
}
print "</tr>"
 }
END{
print "</TABLE></BODY></HTML>"
 }
' ${sorted_final_output} > ${inbound_path}/sorted_final_output_for_entity.html

mutt -e "my_hdr Content-Type: text/html" -s "oozie Job status Report" jasjyot_singh_jaswal@yahoo.com < ${inbound_path}/sorted_final_output_for_entity.html || check_error "Failed to send email"