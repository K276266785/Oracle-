@echo off
echo data output
pause
@rem
cd C:\kai\e\apps\Oracle\Instant Client\bin
sqlplus bietl/Bi#db2019@10.12.153.31:1521/bi @C:\Users\ken.li\Desktop\output.sql
@rem
pause