SELECT	obj.object_name "Object Name",
        obj.object_type "Object Type",
        sess.sid ||', '|| sess.serial# "SID, SERIAL#",  
        sess.status "Session Status",
        sess.username "Database User",
        sess.osuser "OS User",
        sess.machine ||' - '|| sess.terminal "Machine/Terminal" ,
        sess.program "Program"
FROM	v$locked_object lobj, 
        v$session sess, 
        dba_objects obj
WHERE	lobj.session_id = sess.sid
AND		lobj.object_id = obj.object_id;