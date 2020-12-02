select a.tablespace_name, total_bytes/1024/1024 as "Total, MB", used_mbytes as "Used, MB", 
  (total_bytes/1024/1024 - used_mbytes) as "Free, MB" from 
    (select tablespace_name, sum(bytes_used + bytes_free) as total_bytes 
      from v$temp_space_header group by tablespace_name) a, 
    (select tablespace_name, used_blocks*8/1024 as used_mbytes from v$sort_segment) b 
where a.tablespace_name=b.tablespace_name; 
