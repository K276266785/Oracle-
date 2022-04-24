CREATE OR REPLACE PROCEDURE SYS.DB_KILL_IDLE_CLIENTS AUTHID DEFINER AS
  job_no       number;
  num_of_kills number := 0;
  /*
  --Ken Li 2020-03-24
  --模块功能：自动释放session
  */
BEGIN

  FOR REC IN (SELECT SID, SERIAL#, INST_ID, MODULE, STATUS
                FROM gv$session S
               WHERE S.USERNAME IS NOT NULL
                 AND UPPER(S.PROGRAM) IN ('JDBC THIN CLIENT')
                 AND S.LAST_CALL_ET >= 2 * 60 * 60
                 AND S.STATUS = 'INACTIVE'
               ORDER BY INST_ID ASC) LOOP
    ---------------------------------------------------------------------------
    -- kill inactive sessions immediately
    ---------------------------------------------------------------------------
    DBMS_OUTPUT.PUT('LOCAL SID ' || rec.sid || '(' || rec.module || ')');
    execute immediate 'alter system disconnect session ''' || rec.sid || ', ' || rec.serial# || '''immediate';
  
    DBMS_OUTPUT.PUT_LINE('. killed locally ' || job_no);
    num_of_kills := num_of_kills + 1;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Number of killed system sessions: ' || num_of_kills);
  
END DB_KILL_IDLE_CLIENTS;
