SELECT TO_CHAR(s.sid)||','||TO_CHAR(s.serial#) sid_serial, 
 NVL(s.username, 'None') orauser, 
 s.program, 
 r.name undoseg, 
 t.used_ublk * TO_NUMBER(x.value)/1024||'K' "Undo" 
 FROM sys.v_$rollname r, 
 sys.v_$session s, 
 sys.v_$transaction t, 
 sys.v_$parameter x 
 WHERE s.taddr = t.addr 
 AND r.usn = t.xidusn(+) 
 AND x.name = 'db_block_size'; 
