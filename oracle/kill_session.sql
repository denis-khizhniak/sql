set serveroutput on size 20000; 
exec sys.kill.kill_session (sid, serial#); 
