create or replace procedure p_get_table_key_value_bro(a_id       in number,
                                                      a_in_table in varchar2) is
  /*
    --kai 2018-07-02
    --模块功能:table所有列转换为key_value方式
    --参数说明
    --a_id       -- 数据表id值(0=取所有记录)
    --a_in_table -- 待转换的数据表名
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
    
    --默认行号值
    v_rownum := 1;
    
    -- 打开光标
    OPEN cursrc FOR v_sql;
    -- 从本地动态SQL转换为DBMS_SQL
    v_curid  := dbms_sql.to_cursor_number(cursrc);    
    --获取游标里面的数据列项数和每个数据列的属性，比如列名，类型，长度等
    dbms_sql.describe_columns(v_curid, v_colcnt, v_desctab);
    -- 定义列
    FOR i IN 1 .. v_colcnt LOOP
      --此处是定义游标中列的读取类型，可以定义为字符，数字和日期类型，
      IF v_desctab(i).col_type = 2 THEN
        dbms_sql.define_column(v_curid, i, v_vnum);
      ELSIF v_desctab(i).col_type = 12 THEN
        dbms_sql.define_column(v_curid, i, v_vdate);
      ELSE
        dbms_sql.define_column(v_curid, i, v_vname, 50);
      END IF;    
    END LOOP;
    -- DBMS_SQL包获取行
    --从游标中把数据检索到缓存区（BUFFER）中，缓冲区 的值只能被函数COULUMN_VALUE()所读取
    WHILE dbms_sql.fetch_rows(v_curid) > 0 LOOP
      
      FOR i IN 1 .. v_colcnt LOOP
        --取行记录id值
        if v_desctab(i).col_name = 'ID' then
          dbms_sql.column_value(v_curid, i, v_new_id);
        end if;
        
        --重新更新行号
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
      
      --更新行号
      v_old_id := v_new_id;
      v_rownum := v_rownum + 1;
    END LOOP;
  end if;
  --a_out_msg := v_msg;
end;
/
