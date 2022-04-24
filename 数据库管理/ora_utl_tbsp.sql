-- ��ռ�ʹ�����

select /* ��ռ�ʹ����� */ t.tablespace_name,round(sum(bytes_total)/1024/1024)"Total(M)",round(sum(bytes_free)/1024/1024)"Free(M)",round(max(bytes_free)/1024/1024)"LargestFree(M)",round((sum(bytes_total)-sum(bytes_free))/sum(bytes_total)*100,2)"Used(%)"
from(select tablespace_name,bytes bytes_total,0 bytes_free from dba_data_files
union all select tablespace_name,0 bytes_total,bytes bytes_free from dba_free_space
)t group by t.tablespace_name order by 5 desc;

select /* ��ռ估�����ļ� */ t.tablespace_name,max(file_name)"FileName",
round(sum(bytes_total)/1024/1024)"Total(M)",round(sum(bytes_free)/1024/1024)"Free(M)",round(max(bytes_free)/1024/1024)"LargestFree(M)",round((sum(bytes_total)-sum(bytes_free))/sum(bytes_total)*100,2)"Used(%)",max(t.status)"Status",max(t.online_status)"OnlineStatus",max(t.autoextensible)"AutoExtensible"
from(select tablespace_name,file_id,file_name,status,online_status,autoextensible,bytes bytes_total,0 bytes_free from dba_data_files
union all select tablespace_name,file_id,null,null,null,null,0 bytes_total,bytes bytes_free from dba_free_space
)t group by t.tablespace_name,t.file_id order by 1,2;



-- ���ݿ����ռ�ռ��

select /* ���ݿ��û��ռ�ռ�� */ t.*, sum(t."Size(M)")over(partition by t.owner)"Ttl_Size(M)"from(
select t.owner,t.segment_type,
round(sum(t.max_extents)/1024/1024,0)"Max Extents",round(sum(t.bytes)/1024/1024,0)"Size(M)"
from dba_segments t left join dba_tables b on b.owner=t.owner and b.table_name=t.segment_name and t.segment_type='TABLE'
group by t.owner,t.segment_type)t
order by 5 desc,1,2;

select /* ���ݿ����ռ�ռ�� */ t.owner,t.segment_type,t.segment_name,--round(sum(t.max_size)/1024/1024,0)"Max Size(M)",
round(sum(t.max_extents)/1024/1024,0)"Max Extents",round(sum(t.bytes)/1024/1024,0)"Size(M)",b.num_rows
from dba_segments t left join dba_tables b on b.owner=t.owner and b.table_name=t.segment_name and t.segment_type='TABLE'
group by t.owner,t.segment_type,t.segment_name,b.num_rows
order by 5 desc,1,2,3;



-- ѹ����ռ�

select /* ѹ����ռ� */ a.tablespace_name,file_name,ceil((nvl(hwm,1)*c.blksize)/1024/1024)smallest,ceil(blocks*c.blksize/1024/1024)currsize,ceil(blocks*c.blksize/1024/1024)-ceil((nvl(hwm,1)*c.blksize)/1024/1024)savings,
case when blocks-nvl(hwm,1)>0 then 'alter database datafile '''||file_name||''' resize '||ceil((nvl(hwm,1)*c.blksize)/1024/1024/8)*8||'m;'else';'end cmd
from dba_data_files a,
(select file_id,max(block_id+blocks-1)hwm from dba_extents group by file_id)b,
(select value blksize from v$parameter where name='db_block_size')c
where a.file_id=b.file_id(+)
order by 1,2;



-- ������ռ� (max size on win64b is: 4194303blocks, 33554424K)
create tablespace users2 datafile
'D:\apps\oracledbs\users2_01.dbf' size 33554424K,
'D:\apps\oracledbs\users2_02.dbf' size 33554424K,
'D:\apps\oracledbs\users2_03.dbf' size 33554424K autoextend off;

-- ���ӱ�ռ��ļ� (max size on win64b is: 4194303blocks, 33554424K)
alter tablespace users add datafile 'D:\APP\ORACLE\ORADATA\ORCL\USERS01.DBF' size 33554424K autoextend off;

-- ��ռ��ļ����� (max size on win64b is: 4194303blocks, 33554424K)
alter database datafile 'D:\app\oracle\oradata\orcl\USERS01.DBF' resize 33554424K;

-- ��ռ��ļ��Զ���չ
alter database datafile 'D:\app\oracle\oradata\orcl\USERS01.DBF' autoextend off;

-- ���Ķ����ռ�
alter table <table_name> move tablespace <tablespace_name>;
alter index <index_name> rebuild tablespace <tablespace_name>;

-- ɾ����ռ�
drop tablespace users2 including contents cascade constraints;



-- �鿴��ʱ��ռ�
select tablespace_name, file_name, bytes / 1024 / 1024 "SIZE(MB)", autoextensible from dba_temp_files order by 1;

-- ������ʱ��ռ�
create temporary tablespace temp2 tempfile 'D:\app\Administrator\oradata\orcl\TEMP2_1.DBF' size 100m;

-- ��ʱ��ռ��ļ�����
alter database tempfile 'D:\app\Administrator\oradata\orcl\TEMP2.DBF' resize 150m autoextend off;

-- ������ʱ�����ļ�
-- alter tablespace temp2 add tempfile 'D:\app\Administrator\oradata\orcl\TEMP2_2.DBF' size 50m;
