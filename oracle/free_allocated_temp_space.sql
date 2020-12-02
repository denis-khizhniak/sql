select sum(BYTES_CACHED)/1024/1024/1024,sum(BYTES_USED)/1024/1024/1024  from v$temp_extent_pool 
