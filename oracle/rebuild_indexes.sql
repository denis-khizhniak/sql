declare 
cursor uindexes is 
    select index_name from user_indexes; 
    uindex uindexes%rowtype; 
begin 
    for uindex in uindexes loop 
        execute immediate 'alter index '||uindex.index_name||' rebuild'; 
    end loop; 
end; 
/ 
