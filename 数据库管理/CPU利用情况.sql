--5.1 �鿴ÿ��Session��CPU���������
select ss.sid, se.command, ss.value CPU, se.username, se.program
  from v$sesstat ss, v$session se
 where ss.statistic# in
       (select statistic#
          from v$statname
         where name = 'CPU used by this session')
   and se.sid = ss.sid
   and ss.sid > 6
 order by ss.value desc;
--5.2�Ƚ�һ���ĸ�session��CPUʹ��ʱ����࣬Ȼ��鿴��Session�ľ��������
/*
select s.sid, s.event, s.wait_time, w.seq#, q.sql_text
  from v$session_wait w, v$session s, v$process p, v$sqlarea q
 where s.paddr = p.addr
   and s.sid = &p
   and s.sql_address = q.address;
*/
