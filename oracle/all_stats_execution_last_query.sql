select * 
  from table (dbms_xplan.display_cursor( (select sql_id  
                                           from v$sql  
                                          where sql_fulltext like '%%' 
                                            and sql_fulltext not like '%v$sql%') 
                                       , '' 
                                       ,'ALLSTATS LAST' 
                                       ) 
 
) 
