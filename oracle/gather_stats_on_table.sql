begin 
for i in (select  
                ut.TABLE_NAME  from  
                user_tables ut where ut.table_name like 'IDB%' or ut.table_name like 'TFNU%' or ut.table_name like 'MIG%') loop 
                 
  dbms_stats.gather_table_stats(ownname => user,  
                                tabname => i.table_name,  
                                estimate_percent => null, 
                                method_opt => 'FOR ALL COLUMNS SIZE 1', 
                                no_invalidate => false,  
                                cascade => true,  
                                force => true);                                 
end loop; 
 
end; 
/ 
