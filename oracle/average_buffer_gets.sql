SELECT username, 
       buffer_gets, 
       disk_reads, 
       executions, 
       buffer_get_per_exec, 
       parse_calls, 
       sorts, 
       rows_processed, 
       hit_ratio, 
       module, 
       sql_text 
       -- elapsed_time, cpu_time, user_io_wait_time, , 
  FROM (SELECT sql_text, 
               b.username, 
               a.disk_reads, 
               a.buffer_gets, 
               trunc(a.buffer_gets / decode(a.executions, 0, null, a.executions)) buffer_get_per_exec, 
               a.parse_calls, 
               a.sorts, 
               a.executions, 
               a.rows_processed, 
               100 - ROUND (100 * a.disk_reads / decode(a.buffer_gets, 0, null, a.buffer_gets), 2) hit_ratio, 
               a.module 
               -- cpu_time, elapsed_time, user_io_wait_time 
          FROM v$sqlarea a, dba_users b 
         WHERE a.parsing_user_id = b.user_id 
           AND b.username NOT IN ('SYS', 'SYSTEM', 'RMAN','SYSMAN') 
           AND a.buffer_gets > 10000 
         ORDER BY buffer_get_per_exec DESC) 
 WHERE ROWNUM <= 20 
