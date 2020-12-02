select * 
  from (select owner, 
               tablespace_name, 
               round (sum (bytes) / 1024 / 1024) "Occupied, MB" 
          from dba_segments 
         group by owner, tablespace_name 
         order by 3 desc) 
 where rownum <= 20; 
