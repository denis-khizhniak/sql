select (select '(' || sid || ',' || serial# || ',' || username || ',' ||  osuser || ',' || module || ',' || machine || ')'  
   from v$session 
   where sid=a.sid) blocker, ( 
       select '(' || sid || ','  || serial# || ',' || username || ',' ||  osuser || ',' || module || ',' || machine || ')'  
           from v$session where sid=b.sid) blockee from v$lock a, v$lock b 
           where a.block=1 and b.request>0 and a.id1=b.id1 and a.id2=b.id2; 
