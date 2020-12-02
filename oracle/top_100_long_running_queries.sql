select 
    * 
from 
    ( 
        select 
            * 
        from 
            ( 
                select 
                    round(sum(elapsed_time)/1000000,1) total_sec, 
                    sum(EXECUTIONS) exec, 
                    round(sum(elapsed_time)/1000000/sum(EXECUTIONS),1) sec_per_call, 
                    sql_text 
                from 
                    v$sqlarea 
                where 
                    executions <> 0 
                group by 
                    sql_text 
            ) 
        order by 
            sec_per_call desc 
    ) 
where rownum <=100; 
