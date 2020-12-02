select a.tablespace_name, "Free, MB", "Total, MB" 
  from (select tablespace_name, 
         round (sum (bytes) / 1024 / 1024) as "Total, MB" 
          from dba_data_files 
         group by tablespace_name 
         union 
         select tablespace_name, 
          round (sum (bytes) / 1024 / 1024) as "Total, MB" 
           from dba_temp_files 
          group by tablespace_name) a, 
        (select tablespace_name, 
          round (sum (bytes) / 1024 / 1024) as "Free, MB" 
           from dba_free_space 
          group by tablespace_name) b 
 where a.tablespace_name = b.tablespace_name(+) 
 order by a.tablespace_name 
