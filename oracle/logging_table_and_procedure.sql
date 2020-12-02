create table execution_msg_logs (ts timestamp not null, msg varchar2(4000)); 
 
create or replace procedure log_execution_msg (message in varchar2) as  
PRAGMA AUTONOMOUS_TRANSACTION; 
begin 
  insert into execution_msg_logs (ts, msg) 
  values (systimestamp, substr(message, 1, 4000)); 
  commit; 
end log_execution_msg; 
