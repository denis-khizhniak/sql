with  
  t as  
  ( select ';%#' as delimeter 
         , 'asdf;%#ssddf;%#aaaaass' as str  
      from dual  
  ) 
select regexp_substr(t.str, '[^'||t.delimeter||']+', 1, level) from t 
connect by instr(t.str, t.delimeter, 1, level-1) > 0 
