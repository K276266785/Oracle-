select t.COLUMN_NAME from user_tab_columns t where t.TABLE_NAME = 'TB_STK_FX_DT_0A'
minus
select t.COLUMN_NAME from user_tab_columns t where t.TABLE_NAME = 'TB_STK_NU_DT_0A';

select t.COLUMN_NAME from user_tab_columns t where t.TABLE_NAME = 'TB_STK_NU_DT_0A'
minus
select t.COLUMN_NAME from user_tab_columns t where t.TABLE_NAME = 'TB_STK_FX_DT_0A';

-----------------------------
--¿çÊý¾Ý¿â FX/FU/FB/NU/NB
-----------------------------
select t.COLUMN_NAME from dba_tab_columns t where t.OWNER = 'RAY1' and t.TABLE_NAME = 'TB_STK_NU_HD_0A'
minus
select t.COLUMN_NAME from dba_tab_columns t where t.OWNER = 'RAY3' and t.TABLE_NAME = 'TB_STK_NU_HD_0A';

select t.COLUMN_NAME from dba_tab_columns t where t.OWNER = 'RAY3' and t.TABLE_NAME = 'TB_STK_NU_HD_0A'
minus
select t.COLUMN_NAME from dba_tab_columns t where t.OWNER = 'RAY1' and t.TABLE_NAME = 'TB_STK_NU_HD_0A';
