select 
 table_name, 
 decode(type,1,data_total, 2, sum(data_total) over ()) data_total, 
 decode(type,1,indexes_total, 2, sum(indexes_total) over ()) indexes_total, 
 decode(type,1,all_total, 2, sum(all_total) over ()) all_total, 
 decode(type,1,table_size, 2, sum(table_size) over ()) table_size, 
 decode(type,1,iot_size, 2, sum(iot_size) over ()) iot_size, 
 decode(type,1,lob_size, 2, sum(lob_size) over ()) lob_size, 
 decode(type,1,index_size, 2, sum(index_size) over ()) index_size, 
 decode(type,1,lobindex_size, 2, sum(lobindex_size) over ()) lobindex_size 
from 
 ( 
  select 
   table_name, 
   table_size+iot_size+lob_size data_total, 
   index_size+lobindex_size indexes_total, 
   table_size+iot_size+lob_size+index_size+lobindex_size all_total, 
   table_size, 
   iot_size, 
   lob_size, 
   index_size, 
   lobindex_size, 
   1 type 
  from 
   ( 
    select 
     table_name, 
     nvl(floor(sum(table_size)/1024/1024),0) table_size, 
     nvl(floor(sum(iot_size)/1024/1024),0) iot_size, 
     nvl(floor(sum(lob_size)/1024/1024),0) lob_size, 
     nvl(floor(sum(index_size)/1024/1024),0) index_size, 
     nvl(floor(sum(lobindex_size)/1024/1024),0) lobindex_size 
    from 
     ( 
      select 
       case  
        when segment_type='TABLE' then segment_name 
        when segment_type='INDEX' then (select table_name from user_indexes where index_name=s.segment_name) 
        when segment_type='LOBSEGMENT' then (select table_name from user_lobs where segment_name=s.segment_name) 
        when segment_type='LOBINDEX' then (select table_name from user_lobs where index_name=s.segment_name) 
       end table_name, 
       case 
        when segment_type='TABLE' then bytes 
        else 0 
       end table_size, 
       case 
        when segment_type='INDEX' and exists (select 1 from user_indexes where index_name=s.segment_name and index_type='IOT - TOP') then bytes 
        else 0 
       end iot_size, 
       case 
        when segment_type='LOBSEGMENT' then bytes 
        else 0 
       end lob_size, 
       case 
        when segment_type='INDEX' and not exists (select 1 from user_indexes where index_name=s.segment_name and index_type='IOT - TOP') then bytes 
        else 0 
       end index_size, 
       case 
        when segment_type='LOBINDEX' then bytes 
        else 0 
       end lobindex_size 
      from 
       user_segments s 
      where 
       segment_type in ('TABLE', 'INDEX', 'LOBSEGMENT', 'LOBINDEX') 
     ) 
    group by table_name 
   ) 
  union all 
  select 
   'TOTAL:' table_name, 
   0 data_total,  
   0 index_total,  
   0 all_total,  
   0 table_size,  
   0 iot_size,  
   0 lob_size,  
   0 index_size,  
   0 lobindex_size, 
   2 type 
  from dual 
 ) 
order by type, table_name 
; 
