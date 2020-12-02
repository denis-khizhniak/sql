select owner, trunc (sum (bytes / 1024 / 1024)) MB 
  from dba_segments 
 group by owner 
 order by MB desc; 
