create or replace procedure p_dw_smartbi_xml_handle(a_rpt_id in varchar2) is
  /*
  --Ken Li 2020-12-11
  --ģ�鹦��:smartbi����ͳ����ģ��_����xml��Ϣ����
  */

  v_sql      clob;
  v_count    number;
  v_is_inherit varchar2(1000);
  
  v_xml_table varchar2(100);
  v_temp_0a  varchar2(100);
  v_temp_0b  varchar2(100);
  v_temp_0c  varchar2(100);
begin
  v_xml_table := 'tmpp_smartbi_xml_result';
  v_temp_0a := 'dw_smartbi_rpt_role_map';
  v_temp_0b := 'dw_smartbi_rpt_group_map';
  v_temp_0c := 'dw_smartbi_rpt_user_map';
  
  select count(1) into v_count from bietl.dw_smartbi_rpt_tree where rpt_id=a_rpt_id;

  if v_count>0 then
    p_truncate_table(v_xml_table);
    
    --ȡxmlֵ--������ʱ��
    insert into tmpp_smartbi_xml_result
    select XMLType.CreateXML(xml_value) from bietl.dw_smartbi_rpt_tree where rpt_id=a_rpt_id;
    commit;
    
    --��ȡPermission�ڵ������ inherited ���Ա�ǩ--��������� v_is_inherit    
    v_sql :='select extractvalue(b.tc_xml,''/Permissions/@inherited'') as tc_is_inherit
               from '||v_xml_table||' b';
              
    v_sql := 'select max(tc_is_inherit) from ('||v_sql||') t
               where tc_is_inherit is not null';              
    execute immediate v_sql into v_is_inherit;
    --test
    --raise_application_error(-20000, v_is_inherit);

    --��ȡPermission�ڵ������ role ���Ա�ǩ--��������ʱ��
    v_sql :='select extractValue(value(m), ''/@role'') as tc_role_id 
               from '||v_xml_table||' t,
               table(xmlsequence(extract(t.tc_xml,''/Permissions/Permission/@role''))) m';
               
    v_sql :='select '''||a_rpt_id||''' as rpt_id,
                    tc_role_id as role_id
              from ('||v_sql||') t';
    p_ins_tmp_table_bro(v_sql,v_temp_0a);
    commit;
    
    --��ȡPermission�ڵ������ group ���Ա�ǩ--��������ʱ��
    v_sql :='select extractValue(value(m), ''/@group'') as tc_group_id 
               from '||v_xml_table||' t,
               table(xmlsequence(extract(t.tc_xml,''/Permissions/Permission/@group''))) m';
               
    v_sql :='select '''||a_rpt_id||''' as rpt_id,
                    tc_group_id as group_id
              from ('||v_sql||') t';
    p_ins_tmp_table_bro(v_sql,v_temp_0b);
    commit;
    
    --��ȡPermission�ڵ������ user ���Ա�ǩ--��������ʱ��
    v_sql :='select extractValue(value(m), ''/@user'') as tc_user_id 
               from '||v_xml_table||' t,
               table(xmlsequence(extract(t.tc_xml,''/Permissions/Permission/@user''))) m';
                        
    v_sql :='select '''||a_rpt_id||''' as rpt_id,
                    tc_user_id as user_id
              from ('||v_sql||') t';
    p_ins_tmp_table_bro(v_sql,v_temp_0c);
    commit;
    
    --���¡�dw_smartbi_rpt_tree��--��
    if v_is_inherit='true' then
      update bietl.dw_smartbi_rpt_tree
         set tc_is_inherit = 1
       where rpt_id=a_rpt_id;
    end if;
    
    --���´����ʶ
    update bietl.dw_smartbi_rpt_tree
         set tc_is_handle = 1
       where rpt_id=a_rpt_id;
    --�����ύ
    commit;
  end if;
  
  /*exception
  when others then
    raise_application_error(-20000, a_rpt_id);*/
    --rollback;
    
end;
/
