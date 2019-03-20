create or replace procedure p_copy_table_partial_commit(a_source_table in varchar2,
                                                        a_target_table in varchar2) as
  /*
  --Ken Li 2019-03-12
  --模块功能:表复制_分行提交(源表与目标表字段一致)
  --参数说明:
  --a_source_table  --> 来源表
  --a_target_table  --> 目标表
  --v_num           --> 每次提交行数
  */
  
  
  v_sql        varchar2(30000);
  v_column_str varchar2(3000);
  v_rowid      varchar2(100);
  v_num        number;
  v_rownum     number;
  v_count      number;
begin
  --动态表写法
  --------------------------------------
  --取源表行数
  v_sql := 'select count(1) from ' || a_source_table || '@pro_bietl';
  execute immediate v_sql into v_count;
  
  if v_count>0 then
    v_rownum := 1;
    
    --插入日志表
    v_sql := 'insert into tmp_table_copy_log(tc_table_name,tc_count,tc_begin_time) values('''||a_source_table||''','||v_count||',sysdate)';
    execute immediate v_sql;
    commit;
    
    if v_count<100000 then
      --注:小于10万时,采取一次性commit
      v_sql := 'insert into '||a_target_table||' select * from '||a_source_table||'@pro_bietl';
      execute immediate v_sql;
      commit;
    else
      --注:大于10万行时,采用分批commit
      v_num := 3000;--注:每3000行commit一次
      
      --取表所有字段
      v_sql := 'select LISTAGG(column_name, '','') within GROUP(order by column_id)
                  from user_tab_columns
                 where table_name = upper('''||a_target_table||''')';
      execute immediate v_sql into v_column_str;
  
      declare
        type refcursor is ref cursor;
        v_cursor     refcursor;
      begin
        v_sql := 'select rowid from ' || a_source_table || '@pro_bietl';
        open v_cursor for v_sql;
        loop
          fetch v_cursor into v_rowid;
          exit when v_cursor%notfound;
          --ins
          v_sql := 'insert into '|| a_target_table ||'('||v_column_str||')
                    select '||v_column_str||' from ' || a_source_table || '@pro_bietl 
                     where rowid = '''||v_rowid||'''';
          execute immediate v_sql;
                      
          if v_rownum=v_count or mod(v_rownum,v_num)=0 then
            --print_sql
            --p_tmp_ins_output(v_sql,null);
            commit;
          end if;
          
          v_rownum := v_rownum + 1;                    
        end loop;
        close v_cursor;
      end;
    end if;
    
    --更新日志表
    v_sql := 'update tmp_table_copy_log 
                 set tc_end_time = sysdate
               where tc_table_name = '''||a_source_table||'''';
    execute immediate v_sql;
  end if;    
  --------------------------------------
  
  --(静态表写法)--指定表名插入
  --------------------------------------
  /*if v_count>0 then
    declare
      type type_tb is table of t_dim_store%rowtype;
      v_type type_tb;
      v_cur  sys_refcursor;
    begin  
      v_sql := 'select * from ' || a_source_table || '@pro_bietl where rownum<=1000';
      open v_cur for v_sql;
      
      while (true) loop
        fetch v_cur bulk collect into v_type limit 500;
        forall i in 1 .. v_type.count
          insert into t_dim_store values v_type(i);
        commit;
        exit when v_cur%notfound;
      end loop;
      
      close v_cur;
    end;    
  end if;*/
  --------------------------------------
  
  commit;
  exception
  when others then
    rollback;
    raise_application_error(-20001, sqlerrm || '(' || sqlcode || ')');
end;
/
