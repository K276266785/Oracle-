set colsep ,
set feedback off
set heading off
set newp none
set pagesize 0
set linesize 200
set trimout on
 
spool C:\Users\ken.li\Desktop\output.csv

select 'µêÆÌ´úºÅ'||','||'µêÆÌÃû³Æ' from dual
union all 
select * from
(select t.store_code||','||t.store_name from bietl.dw_dim_store t where rownum<=50 
order by t.store_code) tt; 
 
spool off
exit