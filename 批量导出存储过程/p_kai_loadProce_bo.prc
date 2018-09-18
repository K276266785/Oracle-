create or replace procedure p_kai_loadProce_bo(owner in varchar2,
                                               a_out_msg out varchar2) is
  /*
  --kai 2015-04-23
  --模块功能:批量导出存储过程-->生成txt文件
  --参数说明:owner -- (用户:如ray2)
  */
    type user_source_table_type is table of user_source.text%TYPE INDEX BY BINARY_INTEGER;
    user_source_table user_source_table_type;
    file_handle utl_file.file_type;
    stor_text varchar2(4000);
    sql_stat varchar2(1000);
    sql_stat2 varchar2(1000);
    sql_stat3 varchar2(1000);
    nCount number;
    i number;
    v_sql     varchar2(30000);
    v_temp_0a varchar2(100);
begin
  v_temp_0a := 'tmp_kai_proc_list_0a';
  /*---------------------------------------------------------------------------------------------
  --注:使用前先执行
  --设置导出路径
  create or replace directory PROCE_DIR as 'E:/test';
  --赋权语句
  grant create any directory to RAY2;
  --撤权语句
  revoke create any directory from RAY2;
  --查看设置
  select * from dba_directories;
  --------------------------------------------------------------------------------------------- */

  ------------------------------------取指定名称存储过程--------------------------------------
  v_sql := 'select distinct name as tc_old_proc_name,
                   replace(replace(replace(upper(name),''_BRO'',''_ACT''),''_BO'',''_ACT''),''_ACTION'',''_ACT'') as tc_new_proc_name
                   from all_source
                   where owner = ''' || upper(owner) || ''' and
                         type = ''PROCEDURE'' and
                         (upper(text) like ''%_BO(A_KEYARRAY%'' or
                          upper(text) like ''%_BRO(A_KEYARRAY%'' or
                          upper(text) like ''%_ACTION(A_KEYARRAY%'')
                         and name in (''P_VIP_CARD_UDP_BRO'',''P_VIP_ACCCASH_GET_BRO'')';
  p_create_tmp_table_bro(v_sql,v_temp_0a);
  ---------------------------------------------------------------------------------------------

  ------------------------------------导出------------------------------------------------
  sql_stat:='select distinct tc_old_proc_name from '||v_temp_0a;
  execute immediate sql_stat bulk collect into user_source_table;
  file_handle:=utl_file.fopen('PROCE_DIR','test.sql','w');
  for j in 1..user_source_table.count loop
      i:=1;
      sql_stat2:='select max(line) from all_source where owner=''' || upper(owner) || ''' and name=''' || user_source_table(j) || '''';
      --dbms_output.put_line(sql_stat2);
      execute immediate sql_stat2 into nCount;
      WHILE i<=nCount LOOP
         sql_stat3:='select text from all_source where owner=''' || upper(owner) || ''' and name=''' || user_source_table(j) || ''' and line = ' || i;
         --dbms_output.put_line(sql_stat3);
         execute immediate sql_stat3 into stor_text;
         i:=i+1;
       utl_file.put(file_handle,stor_text);
      END LOOP;
  end loop;
  utl_file.fclose(file_handle);
  commit;

  a_out_msg := v_temp_0a;
end;
/
