declare 
 
  v_rows_cnt_arr arrayofstrings; 
  v_table_columns arrayofstrings; 
   
  v_output varchar2(500); 
  v_table_name varchar2(30) := '&table_name'; 
  v_unique_cnt number := 0; 
 
begin 
   
  select column_name 
  bulk collect into v_table_columns 
  from all_tab_columns 
  where 1=1 
    and table_name = upper(v_table_name); 
 
  for rec in v_table_columns.first..v_table_columns.last 
  loop 
    execute immediate  
      'select count(1) as rows_cnt 
       from '||v_table_name||' 
       group by '||v_table_columns(rec)||' 
       having count(1) > 1' 
    bulk collect into v_rows_cnt_arr; 
     
    if v_rows_cnt_arr.count = 0 then  
      v_output := v_output||v_table_columns(rec)||', '; 
      v_unique_cnt := v_unique_cnt + 1; 
    end if; 
  end loop; 
     
  v_output := rtrim(v_output, ', ');   
   
  dbms_output.put_line('Total amount of attributes: '||v_table_columns.count||'.'); 
  dbms_output.put_line('There are ' || v_unique_cnt || ' unique attributes: '||v_output||'.'); 
  dbms_output.put_line(trunc(v_unique_cnt/v_table_columns.count*100, 2)||'% of attributes are unique.');   
   
end; 
