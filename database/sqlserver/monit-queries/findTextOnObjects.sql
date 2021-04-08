DECLARE @Search varchar(255)
BEGIN
    SET @Search='module' --- String that will be searched on the body of procedure, function or view

    SELECT  DISTINCT o.name AS objectName,
            o.type_desc, 
            OBJECT_DEFINITION(o.object_id) AS objectBody
    FROM    sys.sql_modules m
   	INNER   JOIN sys.objects o ON m.object_id=o.object_id
    WHERE   m.definition LIKE '%'+@Search+'%'
    ORDER   BY 2,1
      
    SELECT  A.NAME, A.TYPE, B.TEXT
    FROM    sysobjects  A (NOLOCK)
    JOIN    syscomments B (NOLOCK)
   	ON      A.ID = B.ID
    WHERE   B.TEXT LIKE '%'+@Search+'%'  
    AND     A.TYPE IN ('P','F','V','U','TR')
    /* Object Type that will considered on search
   	    AF = Aggregate function (CLR)
   	    C = CHECK constraint
   	    D = DEFAULT (constraint or stand-alone)
   	    EC = Edge constraint
   	    F = FOREIGN KEY constraint
   	    FN = SQL scalar function
   	    FS = Assembly (CLR) scalar-function
   	    FT = Assembly (CLR) table-valued function
   	    IF = SQL inline table-valued function
   	    IT = Internal table
   	    P = SQL Stored Procedure
   	    PC = Assembly (CLR) stored-procedure
   	    PG = Plan guide
   	    PK = PRIMARY KEY constraint
   	    R = Rule (old-style, stand-alone)
   	    RF = Replication-filter-procedure
   	    S = System base table
   	    SN = Synonym
   	    SO = Sequence object
   	    SQ = Service queue
   	    TA = Assembly (CLR) DML trigger
   	    TF = SQL table-valued-function
   	    TR = SQL DML trigger
   	    TT = Table type
   	    U = Table (user-defined)
   	    UQ = UNIQUE constraint
   	    V = View
   	    X = Extended stored procedure
    */
    ORDER   BY A.NAME
END
