with 
  lst as  
  ( select '&ITEMS' as items 
    from dual 
  ) 
select regexp_replace(items, '(\s+\d+)', ',\1') from lst 
