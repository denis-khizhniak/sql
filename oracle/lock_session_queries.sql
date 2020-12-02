select * from v$lock where block = 1; /*Search lock sessions in LOCK-table, get SID*/ 
select * from v$session where sid = 612; /*Get lock session Serial Number by SID*/ 
begin 
sys.kill.kill_session(612,56611);/*sys.kill.kill_session(SID,Serial Number);*/ 
end; 
 
-------------------------------------------------------------------------------------- 
 
declare 
  kill_sid number(20) := 1396; /*Enter lock session SID*/ 
  kill_serial varchar2(255); 
begin 
  select serial# into kill_serial from v$session where sid = kill_sid; 
  sys.kill.kill_session (kill_sid, kill_serial); 
end; 
 
declare  
  kill_serial arrayofstrings;   
begin 
  select sid ||',' || serial# bulk collect into kill_serial from v$session 
   where sid in (select a.SID from v$session a, v$sort_usage b 
                  where a.saddr = b.session_addr 
                    and a.status = 'INACTIVE' 
                    and a.username = 'U60_Q120_6900');  
    
  if kill_serial.count > 0 
  then 
  FOR i IN kill_serial.FIRST .. kill_serial.LAST 
  LOOP  
  sys.kill.kill_session(substr(kill_serial(i), 0, instr(kill_serial(i), ',') - 1), 
 substr(kill_serial(i), instr(kill_serial(i), ',') + 1)); 
  end loop; 
  end if; 
end; 
 
select s.status, s.sid, s.serial#, p.spid, s.BLOCKING_SESSION, s.SEQ# 
  from v$session s, v$process p 
 where s.paddr = p.addr 
   and s.username = upper('U60_Q120_6900') 
 order by s.sid; 
 
select sid || ',' || serial# sess, username, program, machine, status 
  from v$session 
 where username in 
       ('U60_Q120_6900', 'U60_D109_6960', 'U60_Q120_6860', 'U60_Q120_6820') 
   and lockwait is null 
   and status = 'ACTIVE'; 
  
-------------------------------------------------------------------------------------- 
 
/*Lock sessions tree*/ 
with d_locks as 
 (select * from dba_locks), 
holders as 
 (select w.session_id     waiting_session, 
         h.session_id     holding_session, 
         w.lock_type      lock_type, 
         h.mode_held      mode_held, 
         w.mode_requested mode_requested, 
         w.last_convert   ctime, 
         w.lock_id1       lock_id1, 
         w.lock_id2       lock_id2 
    from d_locks w, d_locks h 
   where h.blocking_others = 'Blocking' 
     and h.mode_held != 'None' 
     and h.mode_held != 'Null' 
     and w.mode_requested != 'None' 
     and w.lock_type = h.lock_type 
     and w.lock_id1 = h.lock_id1 
     and w.lock_id2 = h.lock_id2), 
l_holders as 
 (select * 
    from holders 
  union all 
  select holding_session, null, null, null, null, null, null, null 
    from holders 
  minus 
  select waiting_session, null, null, null, null, null, null, null 
    from holders) 
 
select l_tree.sid "Holder->Waiter", 
       l_tree.lock_type, 
       l_tree.mode_requested, 
       l_tree.mode_held, 
       l_tree.ctime, 
       (case 
         when lock_type = 'Transaction' then 
          (select do.object_name || ': ' || 
                  to_char(dbms_rowid.rowid_create(1, 
                                                  row_wait_obj#, 
                                                  row_wait_file#, 
                                                  row_wait_block#, 
                                                  row_wait_row#)) 
             from dba_objects do 
            where do.object_id = row_wait_obj#) 
         when lock_type = 'DML' then 
          (select owner || '.' || object_name || ' (' || object_type || ')' 
             from dba_objects 
            where object_id = l_tree.lock_id1) 
       end) wait_entity, 
       s.username, 
       s.machine, 
       s.program, 
       s.action, 
       s.status, 
       l_tree.lock_id1, 
       l_tree.lock_id2, 
       (select sql_text 
          from v$sqlarea txt 
         where txt.address = s.sql_address 
           and txt.hash_value = s.sql_hash_value 
           and rownum < 2) current_sql 
  from (select lpad(' ', 2 * (level - 1)) || waiting_session sid, 
               lock_type, 
               mode_requested, 
               mode_held, 
               ctime, 
               lock_id1, 
               lock_id2 
          from l_holders 
         start with holding_session is null 
        connect by holding_session = prior waiting_session 
         order siblings by ctime desc) l_tree, 
       v$session s 
 where s.sid = l_tree.sid 
 
-------------------------------------------------------------------------------------- 
 
select deadlock 
     , lock_size 
     , sid 
     , user_name 
     , ( 
         select object_name || nvl2(procedure_name, '.' || procedure_name, null) 
           from dba_procedures 
          where object_id = plsql_entry_object_id 
            and subprogram_id = plsql_entry_subprogram_id 
            and plsql_entry_object_id > 0 
       ) || ( 
             select ' -> '|| object_name || nvl2(procedure_name, '.' || procedure_name, null) 
               from dba_procedures 
              where object_id = plsql_object_id 
                and subprogram_id = plsql_subprogram_id 
                and plsql_object_id > 0 
            ) AS plsql_procedure 
     , ( SELECT aa.name 
           FROM audit_actions aa 
          WHERE aa.action = command 
            AND aa.action <> 0 
       ) command   
     , ( 
         select to_char(substr(sql_fulltext, 1, 3000)) 
           from v$sql sqls 
          where sqls.hash_value = sql_hash_value 
            and sqls.sql_id = sql_id 
            and sqls.address = sql_address 
            and sqls.child_number = sql_child_number 
            and sql_hash_value > 0 
       ) as sql_text 
     , path 
     , event 
       || case substr(event, 1, 7) 
            when 'enq: TM' then 
                 ( 
                   select '; ' || object_name||' (' || object_id || ')' 
                     from dba_objects 
                    where object_id = row_wait_obj# 
                 ) 
            when 'enq: TX' then 
                 ( 
                   select '; ' || do.object_name || ' (' || row_wait_obj# || '), ' 
                       || TO_CHAR(DBMS_ROWID.rowid_create (1, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#)) 
                     from dba_objects do 
                    where row_wait_obj# = do.object_id 
                  ) 
       end event 
     , program   
     , machine 
     , wait_class 
     , last_call_et 
     , p1text || ': ' || p1 || '; ' || p2text || ': ' || p2 || '; ' || p3text || ': ' || p3 AS params 
     , sql_id 
     , sql_child_number 
     , sql_hash_value 
     , ( SELECT proc.spid 
           FROM v$process proc 
          WHERE proc.addr = paddr 
       ) spid   
     , kill_cmd 
  from ( 
          select /*+ no_merge */ 
                 sid 
               , user_name   
               , command 
               , path 
               , program 
               , machine 
               , event 
               , wait_class 
               , last_call_et 
               , p1text, p1, p2text, p2, p3text, p3 
               , root_wait_time 
               , count(*) over (partition by root) lock_size 
               , row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row# 
               , sql_hash_value, sql_address, sql_child_number, sql_id 
               , paddr 
               , deadlock 
               , plsql_object_id, plsql_subprogram_id, plsql_entry_object_id, plsql_entry_subprogram_id 
               , kill_cmd 
            from ( 
                   select sid               
                        , username AS user_name 
                        , command 
                        , substr(sys_connect_by_path(sid, ' -> '), 5) path 
                        , program 
                          || case 
                               when module is not null and module <> program then 
                                    ' \ ' || module 
                             end 
                          || case 
                               when action is not null and action <> program then 
                                    ' \ ' || action 
                             end AS program 
                        , machine || ' (' || osuser || ')' machine 
                        , blocking_session 
                        , level 
                        , connect_by_root sid AS root 
                        , connect_by_root last_call_et AS root_wait_time 
                        , event 
                        , wait_class 
                        , last_call_et 
                        , p1text, p1, p2text, p2, p3text, p3 
                        , row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row# 
                        , sql_hash_value, sql_address, sql_child_number, sql_id 
                        , paddr 
                        , connect_by_iscycle deadlock 
                        , plsql_object_id, plsql_subprogram_id, plsql_entry_object_id, plsql_entry_subprogram_id 
                        , 'EXEC sys.kill.kill_session(' || sid || ', ' || serial# || ');' kill_cmd 
                     from v$session 
                    start with blocking_session is null 
                    connect by nocycle blocking_session = prior sid 
                 ) 
       ) 
 where (lock_size > 1 or wait_class <> 'Idle') 
  -- and program like '%myprog%' 
  -- and user_name = USER 
 order by lock_size desc, root_wait_time, path; 
