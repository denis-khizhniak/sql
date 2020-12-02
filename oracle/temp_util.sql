select b.tablespace, a.SID, a.serial#, a.username, a.osuser, sum(b.blocks)*8/1024 as "Used, MB" 
from v$session a, v$sort_usage b where 
a.saddr = b.session_addr and a.status = 'INACTIVE' and a.USERNAME = 'U60_Q120_6820' 
group by b.tablespace, a.SID, a.serial#, a.username, a.osuser order by "Used, MB" desc; 
