SELECT 
  /* + RULE */ 
  df.tablespace_name "NC_DATA", 
  df.bytes / (1024*1024*1024) "Size(GB)", 
  SUM(fs.bytes) / (1024*1024*1024) "Free(GB)", 
  NVL(ROUND(SUM(fs.bytes) * 100 / df.bytes),1) "%Free", 
  ROUND((df.bytes         - SUM(fs.bytes)) * 100 / df.bytes) "%Used" 
FROM dba_free_space fs, 
  (SELECT tablespace_name, 
    SUM(bytes) bytes 
  FROM dba_data_files 
WHERE tablespace_name not like 'SCN%' 
  GROUP BY tablespace_name 
  ) df 
WHERE fs.tablespace_name (+) = df.tablespace_name 
GROUP BY df.tablespace_name, df.bytes 
order by 3 desc; 
