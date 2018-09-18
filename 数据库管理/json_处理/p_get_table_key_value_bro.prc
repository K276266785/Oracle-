create or replace procedure p_get_table_key_value_bro(a_id       in number,
                                                      a_in_table in varchar2) is
  /*
    --kai 2018-07-02
    --ģ�鹦��:table������ת��Ϊkey_value��ʽ
    --����˵��
    --a_id       -- ���ݱ�idֵ(0=ȡ���м�¼)
    --a_in_table -- ��ת�������ݱ���
  */     
  v_sql           VARCHAR2(3000);
  v_table_type    varchar2(10);
  TYPE typecursor IS REF CURSOR;
  cursrc          typecursor;
  v_curid         NUMBER;
  v_desctab       dbms_sql.desc_tab;
  v_colcnt        NUMBER;
  v_vname         VARCHAR2(50);
  v_vnum          NUMBER;
  v_vdate         DATE;
  v_new_id        NUMBER;
  v_old_id        number;
  v_rownum        NUMBER;
  v_count         number;
  
  --v_msg   varchar2(10000);
begin
  select count(1)
    into v_count
    from tmpp_table_key_value_0a
   where tc_table_name = upper(a_in_table);
   
  if v_count=0 then   
    select upper(tc_table_type)
      into v_table_type
      from tmpp_json_table_list_0a
     where upper(tc_table_name) = upper(a_in_table);
    
    if a_id=0 then
      v_sql := 'select * from '||a_in_table;
    else
      v_sql := 'select * from '||a_in_table||' where id='||a_id;
    end if;
    
    --Ĭ���к�ֵ
    v_rownum := 1;
    
    -- �򿪹��
    OPEN cursrc FOR v_sql;
    -- �ӱ��ض�̬SQLת��ΪDBMS_SQL
    v_curid  := dbms_sql.to_cursor_number(cursrc);    
    --��ȡ�α������������������ÿ�������е����ԣ��������������ͣ����ȵ�
    dbms_sql.describe_columns(v_curid, v_colcnt, v_desctab);
    -- ������
    FOR i IN 1 .. v_colcnt LOOP
      --�˴��Ƕ����α����еĶ�ȡ���ͣ����Զ���Ϊ�ַ������ֺ��������ͣ�
      IF v_desctab(i).col_type = 2 THEN
        dbms_sql.define_column(v_curid, i, v_vnum);
      ELSIF v_desctab(i).col_type = 12 THEN
        dbms_sql.define_column(v_curid, i, v_vdate);
      ELSE
        dbms_sql.define_column(v_curid, i, v_vname, 50);
      END IF;    
    END LOOP;
    -- DBMS_SQL����ȡ��
    --���α��а����ݼ�������������BUFFER���У������� ��ֵֻ�ܱ�����COULUMN_VALUE()����ȡ
    WHILE dbms_sql.fetch_rows(v_curid) > 0 LOOP
      
      FOR i IN 1 .. v_colcnt LOOP
        --ȡ�м�¼idֵ
        if v_desctab(i).col_name = 'ID' then
          dbms_sql.column_value(v_curid, i, v_new_id);
        end if;
        
        --���¸����к�
        if v_table_type='DT' and v_rownum>1 and v_new_id<>v_old_id then
          v_rownum := 1;
        end if;
        
        IF (v_desctab(i).col_type = 1) THEN
          dbms_sql.column_value(v_curid, i, v_vname);
          insert into tmpp_table_key_value_0a
            (tc_table_name, tc_id, tc_rownum, tc_column_name, tc_value)
          values
            (upper(a_in_table), v_new_id, v_rownum, v_desctab(i).col_name, v_vname);
          --v_msg := v_msg || v_desctab(i).col_name || ' ' || v_vname || ', ';
        ELSIF (v_desctab(i).col_type = 2) THEN
          dbms_sql.column_value(v_curid, i, v_vnum);
          insert into tmpp_table_key_value_0a
            (tc_table_name, tc_id, tc_rownum, tc_column_name, tc_value)
          values
            (upper(a_in_table), v_new_id, v_rownum, v_desctab(i).col_name, v_vnum);
          --v_msg := v_msg || v_desctab(i).col_name || ' ' || v_vnum || ', ';
        ELSIF (v_desctab(i).col_type = 12) THEN
          dbms_sql.column_value(v_curid, i, v_vdate);
          insert into tmpp_table_key_value_0a
            (tc_table_name, tc_id, tc_rownum, tc_column_name, tc_value)
          values
            (upper(a_in_table), v_new_id, v_rownum,v_desctab(i).col_name, to_char(v_vdate, 'YYYY-MM-DD HH24:MI:SS'));
          --v_msg := v_msg || v_desctab(i).col_name || ' ' || to_char(v_vdate, 'YYYY-MM-DD HH24:MI:SS') || ', ';
        END IF;
      END LOOP;
      
      --�����к�
      v_old_id := v_new_id;
      v_rownum := v_rownum + 1;
    END LOOP;
  end if;
  --a_out_msg := v_msg;
end;
/
