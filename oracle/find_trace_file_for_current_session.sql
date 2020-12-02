select 
  (select value from v$parameter where name = 'user_dump_dest') 
  || '/' || 
  (select value from v$parameter where name = 'db_name') 
  || '_ora_' || pr.spid || 
  (select nvl2(value,'_'||value,'') from v$parameter where name = 'tracefile_identifier') || '.trc' 
from 
  v$session sess, 
  v$process pr 
where sess.audsid = userenv('sessionid') 
  and pr.addr = sess.paddr; 
