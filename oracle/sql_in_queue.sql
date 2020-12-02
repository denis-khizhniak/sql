select 
  -- SQL Info 
  ( 
    case when s.PLSQL_ENTRY_OBJECT_ID is not null 
         then 
         ( 
           select object_name || '.' || procedure_name 
           from dba_procedures 
           where object_id = s.PLSQL_ENTRY_OBJECT_ID 
             and SUBPROGRAM_ID = s.PLSQL_ENTRY_SUBPROGRAM_ID 
         ) 
         else '' 
    end 
    || 
    case when s.PLSQL_OBJECT_ID is not null 
          and not (    s.PLSQL_ENTRY_OBJECT_ID = s.PLSQL_OBJECT_ID 
                   and s.PLSQL_ENTRY_SUBPROGRAM_ID = s.PLSQL_SUBPROGRAM_ID 
                  ) 
         then 
         ' ->' || 
         ( 
           select object_name || '.' || procedure_name 
           from dba_procedures 
           where object_id = s.PLSQL_OBJECT_ID 
             and SUBPROGRAM_ID = s.PLSQL_SUBPROGRAM_ID 
         ) 
         else '' 
    end 
  ) as "PL/SQL Procedure", 
  sq.sql_text, 
  -- Wait event info 
  s.event as event_info, 
  --Current wait time (Total query execution time) 
    decode ( 
       s.state, 
       'WAITING', 'WAITING ' || to_char(s.seconds_in_wait), 
       'WAITED SHORT TIME', 'WAITED SHORT', 
       'WAITED UNKNOWN TIME', 'WAITED N/A', 
       'WAITED KNOWN TIME', 'WAITED ' ||  to_char(s.wait_time / 100) 
     ) 
  || ' ('||s.last_call_et||')' as "Wait status/time(last_call_et)", 
  --I/O info 
     round(sq.buffer_gets/decode(sq.executions,0,1,sq.executions),0) || ' gets; ' 
  || round(sq.disk_reads/decode(sq.executions,0,1,sq.executions),0) || ' reads per exec (total ' 
  || decode(sq.executions,0,1,sq.executions) || ' execs)].' as io_info, 
  sq.sql_fulltext, 
  --Binded variables 
  (select to_char( 
            substr( 
              dbms_xmlgen.convert( 
                xmlagg( 
                  xmlelement( 
                    x, 
                    case when value_string is not null 
                         then '[' || name || '=' || value_string || '] ' 
                         else null 
                    end 
                  ) 
                  order by child_address,position 
                ).extract('*/text()').getclobval() 
              ), 
              1, 
              4000 
            ) 
          ) 
          from gv$sql_bind_capture 
          where hash_value = s.sq_hv 
            and address = s.sq_addr 
            and child_number = s.sq_cn 
            and inst_id = s.inst_id 
  ) as bind_variables, 
  --Transaction info 
  case when tr.addr is not null 
       then 'Status: ' 
         || decode (bitand(tr.flag,128),128,'Rolling back',tr.status) 
         || '. Started: ' 
         || tr.start_time 
         || ', (' 
         || to_char(round((sysdate - tr.start_date)*24*60*60,0)) 
         || ' seconds ago. Undo blocks: ' 
         || tr.used_ublk 
         || ').' 
       else null 
  end as transaction_info, 
  s.schemaname, 
  s.inst_id, 
  s.sid, 
  s.serial#, 
  s.client_info, 
  s.machine, 
  s.osuser, 
  s.sql_id, 
  s.* 
from 
  ( 
    select /*+no_merge*/ 
      s1.*, 
      decode (s1.sql_hash_value,0,s1.prev_hash_value,s1.sql_hash_value) as sq_hv, 
      decode (s1.sql_address,'00',s1.prev_sql_addr,s1.sql_address) as sq_addr, 
      decode (s1.sql_child_number,'00',s1.prev_child_number,s1.sql_child_number) as sq_cn 
    from gv$session s1 
    where s1.audsid<>userenv('SESSIONID') 
      and s1.username is not null 
      and (s1.wait_class# != 6 or s1.taddr is not null) 
   ) s, 
   gv$transaction tr, 
   gv$sqlarea sq 
where tr.addr (+)= s.taddr 
  and tr.inst_id (+)= s.inst_id 
  and sq.hash_value (+)= s.sq_hv 
  and sq.address (+) = s.sq_addr 
  and sq.inst_id (+)= s.inst_id 
order by greatest( 
           s.last_call_et, 
           nvl((sysdate - tr.start_date)*24*60*60,0) 
         ) desc 
