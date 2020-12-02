select * 
from (select OWNER 
            ,SEGMENT_NAME 
            ,s.partition_name 
            ,BYTES / 1024 / 1024 SIZE_MB 
        from DBA_SEGMENTS s 
       where /*SEGMENT_TYPE = 'TABLE' 
         and */owner = user 
         and s.tablespace_name = 'NC_DATA' 
       order by BYTES / 1024 / 1024 desc 
     ) 
