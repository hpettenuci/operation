BEGIN
    /*
    Documentação da tabelas de estatísticas:
    https://msdn.microsoft.com/pt-BR/library/ms189741(v=sql.110).aspx
    https://msdn.microsoft.com/pt-br/library/cc280701(v=sql.110).aspx

    @qtde_result    - Determina a quantidade de registros que serão retornados
    @order_type   	 - Utilizar umas das opções abaixo para verificar diferentes TOP consumos
   	 EXE    - execution_count
   	 CPU - avg_worker_time
   	 LGR - avg_logical_reads
   	 LGW - avg_logical_writes
   	 TES - avg_elapsed_time_in_sec
   	 CLR - avg_clr_time
   	 ROW - avg_rows
    @stat_query   	 - Determina de será executada a busca de estatisticas de queries
   	 O - desligado
   	 1 - ligado
    @@stat_proc   	 - Determina de será executada a busca de estatisticas de procedures
   	 O - desligado
   	 1 - ligado
    */
    DECLARE @qtde_result     INT = 15
    DECLARE @order_type   	 NVARCHAR(5) = 'TES'
    DECLARE @stat_query   	 INT = 1
    DECLARE @stat_proc   	 INT = 1

    IF (@stat_query = 1) BEGIN
   	 SELECT * FROM
   	 (SELECT TOP(@qtde_result) SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
   							 ((CASE qs.statement_end_offset
   							 WHEN -1 THEN DATALENGTH(qt.text)
   							 ELSE qs.statement_end_offset
   							 END - qs.statement_start_offset)/2)+1) AS sqlcmd,
   				   qs.execution_count,
   				   ROUND(qs.total_worker_time/qs.execution_count,2) AS avg_worker_time,
   				   ROUND(qs.total_logical_reads/qs.execution_count,2) AS avg_logical_reads,
   				   ROUND(qs.total_logical_writes/qs.execution_count,2) AS avg_logical_writes,
   				   ROUND(qs.total_elapsed_time/qs.execution_count,2) AS avg_elapsed_time,
   				   ROUND(qs.total_clr_time/qs.execution_count,2) AS avg_clr_time,
   				   ROUND(qs.total_rows/qs.execution_count,2) AS avg_rows,
   				   qs.min_rows, qs.max_rows, qs.last_execution_time, qp.query_plan
   	 FROM sys.dm_exec_query_stats qs
   	 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
   	 CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp) tmp_stat
   	 WHERE tmp_stat.sqlcmd NOT LIKE '%msdb.dbo.sysjobhistory%'
   	 ORDER BY CASE    
   				 WHEN @order_type='EXE' THEN tmp_stat.execution_count
   				 WHEN @order_type='CPU' THEN tmp_stat.avg_worker_time
   				 WHEN @order_type='LGR' THEN tmp_stat.avg_logical_reads
   				 WHEN @order_type='LGW' THEN tmp_stat.avg_logical_writes
   				 WHEN @order_type='TES' THEN tmp_stat.avg_elapsed_time
   				 WHEN @order_type='CLR' THEN tmp_stat.avg_clr_time
   				 WHEN @order_type='ROW' THEN tmp_stat.avg_rows
   			  END DESC
    END

    IF (@stat_proc = 1) BEGIN
    SELECT * FROM
    (SELECT    TOP(@qtde_result) DB_NAME(ps.database_id) AS DBNAME,
   		 OBJECT_NAME(ps.object_id, ps.database_id) AS PROCNAME,
   		 SUM(ps.execution_count) AS execution_count,
   		 ROUND(SUM(ps.total_worker_time)/SUM(ps.execution_count),2) AS avg_worker_time,
   		 ROUND(SUM(ps.total_logical_reads)/SUM(ps.execution_count),2) AS avg_logical_reads,
   		 ROUND(SUM(ps.total_logical_writes)/SUM(ps.execution_count),2) AS avg_logical_writes,
   		 ROUND(SUM(ps.total_elapsed_time)/SUM(ps.execution_count),2) AS avg_elapsed_time,
   		 MAX(ps.last_execution_time) AS last_execution_time
    FROM    sys.dm_exec_procedure_stats ps
    WHERE    DB_NAME(ps.database_id) IN ('AAD','ADV')
    GROUP    BY ps.database_id, ps.object_id) tmp_stat_p
    ORDER    BY CASE    
   			 WHEN @order_type='EXE' THEN tmp_stat_p.execution_count
   			 WHEN @order_type='CPU' THEN tmp_stat_p.avg_worker_time
   			 WHEN @order_type='LGR' THEN tmp_stat_p.avg_logical_reads
   			 WHEN @order_type='LGW' THEN tmp_stat_p.avg_logical_writes
   			 WHEN @order_type='TES' THEN tmp_stat_p.avg_elapsed_time
   			 ELSE tmp_stat_p.avg_worker_time
   		 END DESC
    END
END