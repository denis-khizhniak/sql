select owner, table_name, trunc (sum (bytes) / 1024 / 1024) "Occupied, MB" 
  from (select segment_name table_name, owner, bytes 
          from dba_segments 
         where segment_type = 'TABLE' 
        union all 
        select i.table_name, i.owner, s.bytes 
          from dba_indexes i, dba_segments s 
         where s.segment_name = i.index_name 
           and s.owner = i.owner 
           and s.segment_type = 'INDEX' 
        union all 
        select l.table_name, l.owner, s.bytes 
          from dba_lobs l, dba_segments s 
         where s.segment_name = l.segment_name 
           and s.owner = l.owner 
           and s.segment_type = 'LOBSEGMENT' 
        union all 
        select l.table_name, l.owner, s.bytes 
          from dba_lobs l, dba_segments s 
         where s.segment_name = l.index_name 
           and s.owner = l.owner 
           and s.segment_type = 'LOBINDEX') 
 where owner in upper ('&owner') /*Set your schema name, for example U60_Q120_6800*/ 
 group by table_name, owner 
having sum (bytes) / 1024 / 1024 > 10 /* Ignore really small tables */ 
 order by sum (bytes) desc; 
