select (select decode(extent_management, 'LOCAL', '*', ' ') || 
               decode(segment_space_management, 'AUTO', 'a ', 'm ') 
          from dba_tablespaces 
         where tablespace_name = b.tablespace_name 
       ) || nvl(b.tablespace_name, nvl(a.tablespace_name, 'UNKOWN')) 
       as name 
      ,mbytes_alloc mbytes 
      ,mbytes_alloc - nvl(mbytes_free, 0) as used 
      ,nvl(mbytes_free, 0) as free 
      ,round(((mbytes_alloc - nvl(mbytes_free, 0)) / mbytes_alloc) * 100,2) || '%' as pct_used 
      ,nvl(largest, 0) as largest 
      ,nvl(mbytes_max, mbytes_alloc) as Max_Size 
      ,round(decode(mbytes_max, 0, 0, (mbytes_alloc / mbytes_max) * 100),2) || '%' as pct_max_used 
  from (select sum(bytes) / 1024 / 1024 mbytes_free 
              ,max(bytes) / 1024 / 1024 largest 
              ,tablespace_name 
          from sys.dba_free_space 
         group by tablespace_name 
       ) a 
      ,(select sum(bytes) / 1024 / 1024 mbytes_alloc 
             ,sum(maxbytes) / 1024 / 1024 mbytes_max 
             ,tablespace_name 
         from sys.dba_data_files 
        group by tablespace_name 
       union all 
       select sum(bytes) / 1024 / 1024 mbytes_alloc 
             ,sum(maxbytes) / 1024 / 1024 mbytes_max 
             ,tablespace_name 
         from sys.dba_temp_files 
        group by tablespace_name 
       ) b 
 where a.tablespace_name(+) = b.tablespace_name 
