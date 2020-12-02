select q.sql_id 
     , s.sid 
     , s.serial# 
     , q.sql_text 
     , q.sql_fulltext 
     , slo.sofar 
     , slo.totalwork 
     , slo.elapsed_seconds 
     , slo.time_remaining 
     , slo.sql_plan_line_id 
     , slo.sql_plan_operation 
  from v$session s 
       join v$sql q on s.sql_address = q.address 
       join v$session_longops slo  
         on slo.sql_id = q.sql_id 
        and slo.sofar != slo.totalwork 
 where s.status = 'ACTIVE' 
   and s.username = &user
