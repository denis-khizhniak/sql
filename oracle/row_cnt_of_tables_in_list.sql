declare 
  v_tbl_list varchar2(4000) :=  
    'R_BOE_SALES_ORD;R_BOE_ORD_ITEM;R_BOE_BSNS_PROD_INST;R_CBM_PREPAID_BILLING_ACCT;' || 
    'R_CBM_POSTPAID_BILLING_ACCT;R_CIM_BSNS_CUST_ACCT;R_BOE_CALCULATED_PRICE;R_AM_MRKT_CLASSIFICATION;R_CNTM_ADDIT_AGRM;R_CNTM_COM_AGRM;' || 
    'R_BOE_ORD_MGMT_PROJECT;R_PMGT_STORE;R_CIM_RES_CUST_ACCT;R_CIM_BSNS_CUST_ACCT'; 
   
  cursor tables_cur 
  is 
  select regexp_substr(str, '[^;]+', 1, level) as tbl 
  from (select v_tbl_list as str from dual) s 
  connect by instr(str, ';', 1, level-1) > 0; 
   
  v_cnt varchar2(20); 
begin 
   
  for rw in tables_cur 
  loop 
    execute immediate 'select count(1) as cnt from ' || rw.tbl 
    into v_cnt;    
    dbms_output.put_line(rw.tbl || ': ' || v_cnt || ' row(s)'); 
  end loop; 
   
end; 
