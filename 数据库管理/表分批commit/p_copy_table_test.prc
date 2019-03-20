create or replace procedure p_copy_table_test(a_source_table in varchar2,
                                              a_target_table in varchar2) as
  /*
  --Ken Li 2019-03-13
  --ģ�鹦��:����_�����ύ(Դ����Ŀ����ֶ�һ��)
  --����˵��:
  --a_source_table  --> ��Դ��
  --a_target_table  --> Ŀ���
  --ע:����<=5����ʱ����һ���Բ���,����5��ʱÿ3000�н���һ���ύ
  */
  v_sql        varchar2(30000);
  v_count      number;

begin
  --ȡԴ������
  v_sql := 'select count(1) from ' || a_source_table || '@pro_bietl';
  execute immediate v_sql into v_count;

  if v_count>0 then
    --������־��
    v_sql := 'insert into tmp_table_copy_log(tc_table_name,tc_count,tc_begin_time) values('''||a_target_table||''','||v_count||',sysdate)';
    execute immediate v_sql;
    commit;

    if v_count<=50000 then
      --ֱ��commit
      ------------------------------------------------------------
      v_sql := 'insert into '||a_target_table||' select * from '||a_source_table||'@pro_bietl';
      execute immediate v_sql;
      commit;
      ------------------------------------------------------------
    else
      --����commit(ÿ3000���ύһ��)
      ------------------------------------------------------------
      v_sql := '
        declare
          type type_tb is table of '||a_target_table||'%rowtype;
          v_type   type_tb;
          v_query  varchar2(30000);
          v_cur    sys_refcursor;
        begin
          v_query :=''select * from '||a_source_table||'@pro_bietl where 1=1'' ;
          open v_cur for v_query;

          while (true) loop
            fetch v_cur bulk collect into v_type limit 3000;
            forall i in v_type.first .. v_type.last
              insert into  ' || a_target_table || ' values v_type(i);
              commit;
            exit when v_cur%notfound;
          end loop;

          close v_cur;
        end;';
      execute immediate v_sql;
      -------------------------------------------------------------
    end if;

    --������־��
    v_sql := 'update tmp_table_copy_log
                 set tc_end_time = sysdate
               where tc_table_name = '''||a_target_table||'''';
    execute immediate v_sql;
    commit;
  end if;

  --ע:�ο�demo(��̬��д��)--ָ����������
  --------------------------------------
  /*declare
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
  end;*/
  --------------------------------------
end;
/
