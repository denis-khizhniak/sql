declare 
 
  v_column_combs arrayofstrings; 
   
  v_rows_cnt number := 0;   
  v_table_name varchar2(30) := '&tbl_name'; 
  v_min_comb_col_cnt number; 
  v_comb_col_cnt number; 
 
  cursor col_str_cur 
  is 
    select col_str 
    from  
      (select  
         ltrim(sys_connect_by_path(column_name, ','), ',') as col_str 
        ,length(ltrim(sys_connect_by_path(column_name, ','), ',')) - length(replace(ltrim(sys_connect_by_path(column_name, ','), ','), ','))+1 as col_cnt 
      from  
        (select  
           column_name 
          ,rownum as colnum  
        from  
          all_tab_columns 
        where 1=1 
          and table_name = upper(v_table_name)) sq 
      connect by  
        prior colnum < colnum 
      order by 2) 
  where 1=1   
  ; 
       
begin 
   
  select count(1)  
  into v_min_comb_col_cnt 
  from    
    all_tab_columns 
  where 1=1 
    and table_name = upper(v_table_name); 
 
  open col_str_cur; 
  <<cursor_loop>> 
  loop 
     
    fetch col_str_cur bulk collect into v_column_combs limit 1000; 
    exit when v_column_combs.count = 0; 
     
    <<collection_loop>>   
    for idx in v_column_combs.first..v_column_combs.last           
    loop 
      v_comb_col_cnt := length(v_column_combs(idx)) - length(replace(v_column_combs(idx), ',')) + 1; 
       
      execute immediate 
        'select count(1) 
        from 
          (select '||v_column_combs(idx)||', count(1) as cnt 
          from '||v_table_name||' 
          group by '||v_column_combs(idx)||' 
          having count(1) > 1)' 
      into v_rows_cnt; 
       
      if (v_rows_cnt = 0 and v_comb_col_cnt <= v_min_comb_col_cnt) then 
        v_min_comb_col_cnt := v_comb_col_cnt; 
        dbms_output.put_line(v_column_combs(idx)); 
      end if;       
       
      exit cursor_loop when v_comb_col_cnt > v_min_comb_col_cnt; 
       
    end loop;     
  end loop; 
   
  close col_str_cur; 
   
end; 
