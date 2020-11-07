SELECT  tran.start_time "Date/Time Trasaction Start", 
        sess.logon_time "Date/Time Logon", 
        sess.sid ||', '|| sess.serial# "SID, SERIAL#",  
        sess.username "User", 
        sess.status "Session Status", 
      	sess.prev_exec_start "Date/Time Command Start", 
        cmd.sql_text "Último comando executado"
FROM 	v$transaction tran, 
        gv$session sess, 
        v$sql cmd
WHERE	sess.saddr = tran.ses_addr
AND 	sess.prev_child_number = cmd.child_number 
AND 	sess.prev_sql_id = cmd.sql_id;