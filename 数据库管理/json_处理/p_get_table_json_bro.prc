create or replace procedure p_get_table_json_bro(a_id      number,
                                                 a_out_msg out varchar2) is

  /*
  --kai 2018-07-01
  --模块功能:通用table结果转--json数组
  --注:只支持单个id结果转换
  */
  v_sql                        varchar2(30000);
  v_msg_hd                     varchar2(10000);
  v_msg_dt                     varchar2(10000);

  --v_msg_hd_result              varchar2(20000);
  v_msg_dt_result              varchar2(20000);
  v_msg                        varchar2(30000);
  v_msg1                       varchar2(30000);
  v_msg2                       varchar2(30000);
  
  v_table_hd_name              varchar2(100);
  v_table_dt_name              varchar2(100);
  v_table_dt_qty               number;
  v_table_dt_num               number;
  v_id                         number;
  v_count                      number;
  v_hd_rownum                  number;
  v_dt_rownum                  number;
  v_json_hd_name               varchar2(100);
  v_json_dt_name               varchar2(100);

begin
  select upper(tc_table_name)
      into v_table_hd_name
      from tmpp_json_table_list_0a
     where upper(tc_table_type) = 'HD';
  
  select count(1)
      into v_table_dt_qty
      from tmpp_json_table_list_0a
     where upper(tc_table_type) = 'DT';
        
  if a_id=0 then
    raise_application_error(-20000, '暂不支持hd多记录！');
    
    v_sql := 'select count(1) from '||v_table_hd_name;
    execute immediate v_sql into v_hd_rownum;
  else
    v_hd_rownum := 1;
  end if;
  
  select tc_json_hd
    into v_json_hd_name
    from tmpp_json_table_list_0a
   where upper(tc_table_name) = upper(v_table_hd_name);
  
  for i in 1..v_hd_rownum loop
    if a_id=0 then
      v_sql := 'select distinct tc_id from tmpp_table_key_value_0a
                 where tc_table_name = '''||v_table_hd_name||''' and
                       tc_rownum = '||i;
      execute immediate v_sql into v_id;
    else
      v_id := a_id;
    end if;
    
    --取hd结果json
    v_sql := 'select wm_concat(''"''||tc_column_name||''":"''||tc_value||''"'') from tmpp_table_key_value_0a
               where tc_table_name = '''||v_table_hd_name||''' and
                     tc_id = '||v_id;
    execute immediate v_sql into v_msg_hd;

    declare
      type refcursor is ref cursor;
      v_cursor     refcursor;
    begin
      v_table_dt_num := 1;
      v_sql := 'select upper(tc_table_name),tc_json_hd from tmpp_json_table_list_0a where upper(tc_table_type)=''DT''';
      open v_cursor for v_sql;
      loop
        fetch v_cursor into v_table_dt_name, v_json_dt_name;
        exit when v_cursor%notfound;

        v_sql := 'select count(1) from '||v_table_dt_name||' where id='||v_id;
        execute immediate v_sql into v_count;
        
        if v_count>0 then
          v_sql := 'select count(distinct tc_rownum) from tmpp_table_key_value_0a 
                     where tc_table_name = '''||v_table_dt_name||''' and 
                           tc_id='||v_id;
          execute immediate v_sql into v_dt_rownum;
          
          v_msg_dt_result := '';
          for j in 1..v_dt_rownum loop
            --取dt结果json
            v_sql := 'select ''{''||wm_concat(''"''||tc_column_name||''":"''||tc_value||''"'')||''}'' from tmpp_table_key_value_0a
                             where tc_table_name = '''||v_table_dt_name||''' and
                                   tc_id = '||v_id||' and
                                   tc_rownum = '||j;                                            
            execute immediate v_sql into v_msg_dt;
            
            if j<v_dt_rownum then
              v_msg_dt := v_msg_dt||',';
            end if;
            v_msg_dt_result := v_msg_dt_result||v_msg_dt;
          end loop;   
          
          v_msg1 := '"'||v_json_dt_name||'":['||v_msg_dt_result||']';  
          v_msg2 := v_msg2||v_msg1; 
          
          if v_table_dt_num<v_table_dt_qty then
            v_msg2 := v_msg2||',';
          end if;    
          --序号+1
          v_table_dt_num := v_table_dt_num+1;           
        end if;
      end loop;      
      close v_cursor;
    end;

    if v_msg2 is not null then
      v_msg := '{'||v_msg_hd||','||v_msg2||'}';
    else
      v_msg := '{'||v_msg_hd||'}';
    end if;

    if i<v_hd_rownum then
      v_msg := v_msg||',';
    end if;
  end loop;

  --最终结果
  v_msg := '{"'||v_json_hd_name||'":'||v_msg||'}';

  a_out_msg := v_msg;
end;
/
