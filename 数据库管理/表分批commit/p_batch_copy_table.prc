create or replace procedure p_batch_copy_table as
  /*
  --Ken Li 2019-03-12
  --ģ�鹦��:�������Ʊ�
  */
  v_sql        varchar2(30000);
  v_table_name varchar2(100);
  v_table_list varchar2(100);
  v_count      number;
  v_rowid      number;
begin
  v_table_list := 'tmp_copy_table_list';

  --1.ȡҪ���Ƶ����ݱ��嵥
  v_sql := 'select rownum as tc_rowid,
                   table_name as tc_table_name from user_tables
            where table_name like ''T_DIM%'' or
                  table_name like ''T_FACT%'' or
                  table_name like ''DM_%'' or
                  table_name like ''T_DM%''';
  p_create_tmp_table_bro(v_sql,v_table_list);

  v_sql := 'select count(1) from '||v_table_list;
  execute immediate v_sql into v_count;

  if v_count>0 then
    for i in 1..v_count loop
      v_sql := 'select tc_table_name from '||v_table_list||' where tc_rowid='||i;
      execute immediate v_sql into v_table_name;

      --���ñ���
      p_copy_table_partial_commit(v_table_name,v_table_name);
    end loop;
  end if;
end;
/
