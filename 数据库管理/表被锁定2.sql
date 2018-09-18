--��ѯ��ʱ��SQL����ʱ��
select l.opname, l.target, l.elapsed_seconds, l.time_remaining, s.sql_text
  from v$session_longops l, v$sqlarea s
 where l.sql_address = s.address
 order by l.elapsed_seconds desc;

--�鿴�Ŷӽ��̣��ϼƣ�
select count(1)
  from v$locked_object l, v$session s, all_objects o, v$process p
 where p.addr = s.paddr
   and s.process = l.process
   and o.object_id = l.object_id
 order by l.os_user_name,
          l.oracle_username,
          l.session_id,
          p.spid,
          s.sid,
          s.serial#,
          o.object_name;

--�鿴�Ŷӽ���(�嵥)          
select l.os_user_name as client_os_user_name,
       l.oracle_username,
       l.session_id,
       s.sid,
       s.serial#,
       p.spid,
       o.object_name
  from v$locked_object l, v$session s, all_objects o, v$process p
 where p.addr = s.paddr
   and s.process = l.process
   and o.object_id = l.object_id
 order by l.os_user_name,
          l.oracle_username,
          l.session_id,
          p.spid,
          s.sid,
          s.serial#,
          o.object_name;

--����ɱ����������SQL
select distinct s.sid,
       s.machine,
       o.object_name,
       l.oracle_username,
       l.locked_mode,
       'ALTER  SYSTEM  KILL  SESSION  ''' || s.sid || ',  ' || s.serial# ||
       ''';' Command
  from v$locked_object l, v$session s, all_objects o
 where l.session_id = s.sid
   and l.object_id = o.object_id;

--=========================================================================
--=========================================================================
--oracle��ȥ���ֶ��еĻس���
/*update ywj_yxglobj
   set table_name = replace(table_name, chr(10), '')
 where table_name like 'ACCT_INFO%';*/