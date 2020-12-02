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
