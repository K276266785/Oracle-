Load data
CHARACTERSET 'UTF8' 
infile 'C:\kai\e\bak\常用SQL\Oracle学习资料\oracle读写文件\大数据文件导入oracle\test.txt'   
REPLACE into table tmp_e3_old_tid_map         
fields terminated by "," 
optionally enclosed by '\n'  
trailing nullcols
(tc_ec_tid,tc_sub_ec_tid)
