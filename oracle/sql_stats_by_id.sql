select * from table(DBMS_XPLAN.display_cursor(sql_id => '11')) 
