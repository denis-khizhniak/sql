select 'begin sys.kill.kill_session('||sid||','||serial#||'); end;' kill_command, 
       vs.sid,vs.serial#,status,schemaname,osuser,machine,program,logon_time, 
       to_char(numtodsinterval(last_call_et,'second')+to_date('1','y'),'hh24:mi:ss') session_time_wait, 
       (select sql_text from v$sqlarea where address=vs.sql_address) sql_text 
  from v$session vs 
where status='ACTIVE' and schema#>0 
order by 10 desc nulls last; 
