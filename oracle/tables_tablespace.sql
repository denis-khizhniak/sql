select * from user_objects where object_name in (select table_name 
from dba_tables 
where tablespace_name  = '#TableSpace Name#') 
order by created desc;
