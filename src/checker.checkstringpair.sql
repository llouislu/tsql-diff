drop PROCEDURE if EXISTS Checker.CheckStringPair
GO
CREATE PROCEDURE Checker.CheckStringPair
    -- return values
    -- 0 success
    -- 1 execution errors(file not found, syntax error, not containing SELECT)
    -- 2 column datatypes not matched
    -- 4 column order not matched
    -- 8 column names not matched
    -- 16 column data row order not matched

    @EXP_QueryString NVARCHAR(max),
    @ACT_QueryString NVARCHAR(max),
    @ExplicitColumnOrder TINYINT = 1,
    @ExplicitColumnName TINYINT = 1,
    @ExplicitRowOrder TINYINT = 1
AS
BEGIN
    DECLARE @status_code INT = 0;

    /*
        save expected query result
    */
    -- fetch metadata of the result
    IF OBJECT_ID('tempdb..#__EXP_ResultMeta') IS NOT NULL DROP TABLE #__EXP_ResultMeta;
    CREATE TABLE #__EXP_ResultMeta
    (
        name nvarchar(256),
        dtype nvarchar(128)
    );
    EXEC Checker.Private_FetchResultMetaData @EXP_QueryString;
    INSERT INTO #__EXP_ResultMeta
    SELECT name, system_type_name as dtype FROM ##ResultStructure;
    DECLARE @EXP_isSelect INT;
    select @EXP_isSelect=count(*)
    from #__EXP_ResultMeta
    -- print 'sssssss';
    -- select * from #__EXP_ResultMeta;
    -- no select statement is query
    if @EXP_isSelect=0
    BEGIN
        PRINT concat_ws(' ', 'No "SELECT" statement in query:', @EXP_QueryString)
        return 1
    END

    -- build SQL to build temp table to hold results
    DECLARE @EXP_BuildResultTableSQL NVARCHAR(max);
    select @EXP_BuildResultTableSQL=concat_ws(' ', concat('drop table if exists ##', 'Expected'), ';', concat('create table ##', 'Expected'), '(', '__id__ INT IDENTITY PRIMARY KEY, ', string_agg(concat_ws(' ', name, dtype), ', '), ')')
    from #__EXP_ResultMeta
    -- print @EXP_BuildResultTableSQL
    EXEC sp_executesql @EXP_BuildResultTableSQL;

    -- run sql and store result to the temp table built above
    DECLARE @EXP_RealSQLString NVARCHAR(max), @EXP_ResultTableColumnNames NVARCHAR(max);
    SELECT @EXP_ResultTableColumnNames=string_agg(name, ', ')
    FROM #__EXP_ResultMeta
    -- 'SELECT * INTO ' + @expectedTableName + ' FROM (' + @sqlToRun + ') AS ' + @expectedTableName;
    DECLARE @EXP_InsertStatement NVARCHAR(max);
    SELECT @EXP_InsertStatement = concat_ws(' ', 'insert into', concat('##', 'Expected'), '(', @EXP_ResultTableColumnNames, ')');
    SELECT @EXP_RealSQLString = concat(@EXP_InsertStatement, @EXP_QueryString)
    -- print @EXP_RealSQLString;
    EXEC sp_executesql @EXP_RealSQLString;


    /*
        save actual query result
    */
    IF OBJECT_ID('tempdb..#__ACT_ResultMeta') IS NOT NULL DROP TABLE #__ACT_ResultMeta;
    CREATE TABLE #__ACT_ResultMeta
    (
        name nvarchar(256),
        dtype nvarchar(128)
    );
    -- fetch metadata of the result
    EXEC Checker.Private_FetchResultMetaData @ACT_QueryString;
    
    INSERT INTO #__ACT_ResultMeta
    SELECT name, system_type_name as dtype
    FROM ##ResultStructure;
    -- debug: result structure
    -- select * from #__ACT_ResultMeta

    DECLARE @ACT_isSelect INT;
    select @ACT_isSelect=count(*)
    from #__ACT_ResultMeta
    -- no select statement is query
    if @ACT_isSelect=0
        BEGIN
        -- PRINT concat_ws(' ', 'No "SELECT" statement in query:')
        return 1
        END

    -- build SQL to build temp table to hold results
    DECLARE @ACT_BuildResultTableSQL NVARCHAR(max);
    select @ACt_BuildResultTableSQL=concat_ws(' ', concat('drop table if exists ##', 'Actual'), ';', concat('create table ##', 'Actual'), '(', '__id__ INT IDENTITY PRIMARY KEY, ', string_agg(concat_ws(' ', name, dtype), ', '), ')')
    from #__ACT_ResultMeta
    -- print @ACT_BuildResultTableSQL
    EXEC sp_executesql @ACT_BuildResultTableSQL;

    -- run sql and store result to the temp table built above
    DECLARE @ACT_RealSQLString NVARCHAR(max), @ACT_ResultTableColumnNames NVARCHAR(max);
    SELECT @ACT_ResultTableColumnNames=string_agg(name, ', ')
    FROM #__ACT_ResultMeta
    DECLARE @ACT_InsertStatement NVARCHAR(max);
    SELECT @ACT_InsertStatement = concat_ws(' ', 'insert into', concat('##', 'Actual'), '(', @ACT_ResultTableColumnNames, ')');
    SELECT @ACT_RealSQLString = concat(@ACT_InsertStatement, @ACT_QueryString)
    -- print @ACT_RealSQLString;
    EXEC sp_executesql @ACT_RealSQLString;


    /*
      Compare results here
    */
    
    -- results in table ##Expected, ##Actual
    -- metadata tables: #__EXP_ResultMeta, #__ACT_ResultMeta

    -- check if the two sets of column datatypes are same
    DECLARE @EXP_column_set NVARCHAR(max), @ACT_column_set NVARCHAR(max);
    select @EXP_column_set=string_agg(dtype, '|') within group (order by dtype) from #__EXP_ResultMeta;
    select @ACT_column_set=string_agg(dtype, '|') within group (order by dtype) from #__ACT_ResultMeta;
    BEGIN TRY
        EXEC tSQLt.AssertEqualsString @EXP_column_set, @ACT_column_set;
    END TRY
    BEGIN CATCH
        -- the two sets of column datatypes NOT SAME
        -- PRINT concat_ws(' ', '!EXPECTED COLUMN DATATYPE(S) NOT MATCHED:')
        return 2
    END CATCH

    -- @ExplicitColumnOrder TINYINT = 1
    IF @ExplicitColumnOrder=1
    BEGIN
        DECLARE @EXP_col_order NVARCHAR(max), @ACT_col_order NVARCHAR (max);
        select @EXP_col_order=string_agg(dtype, '|') from #__EXP_ResultMeta;
        select @ACT_col_order=string_agg(dtype, '|') from #__ACT_ResultMeta;
    END
    BEGIN TRY
        EXEC tSQLt.AssertEqualsString @EXP_col_order, @ACT_col_order;
    END TRY
    BEGIN CATCH
        -- the two sets of column datatypes NOT SAME
        -- PRINT concat_ws(' ', '!EXPECTED COLUMN ORDER NOT MATCHED')
        SET @status_code += 4
    END CATCH

    -- @ExplicitColumnName TINYINT = 1
    IF @ExplicitColumnName=1
    BEGIN
        DECLARE @EXP_column_name_set NVARCHAR(max), @ACT_column_name_set NVARCHAR(max);
        select @EXP_column_name_set=string_agg(name, '|') within group (order by name) from #__EXP_ResultMeta;
        select @ACT_column_name_set=string_agg(name, '|') within group (order by name) from #__ACT_ResultMeta;
        BEGIN TRY
            EXEC tSQLt.AssertEqualsString @EXP_column_name_set, @ACT_column_name_set;
        END TRY
        BEGIN CATCH
            -- the two sets of column datatypes NOT SAME
            -- PRINT concat_ws(' ', '!EXPECTED COLUMN NAME(S) NOT MATCHED')
            SET @status_code += 8
        END CATCH        
    END

    -- @ExplicitRowOrder TINYINT = 1
    IF @ExplicitRowOrder=1
    BEGIN
    DECLARE @EXP_column_name_alias NVARCHAR(max), @ACT_column_name_alias NVARCHAR(max);
    -- re-order column names by data types and give column aliases such as "1", "2", "3"...
    select @EXP_column_name_alias=string_agg(col_name, ', ') from (select concat_ws(' ', name, 'AS', concat('"', ROW_NUMBER() over(order by dtype ASC), '"')) as col_name from #__EXP_ResultMeta) as t;
    select @ACT_column_name_alias=string_agg(col_name, ', ') from (select concat_ws(' ', name, 'AS', concat('"', ROW_NUMBER() over(order by dtype ASC), '"')) as col_name from #__ACT_ResultMeta) as t;
    
    -- show new colun name with datatype after the re-ordering
    DECLARE @EXP_column_name_dtype NVARCHAR(max), @ACT_column_name_dtype NVARCHAR(max);
    select @EXP_column_name_dtype=string_agg(col_name, ', ') from (select concat_ws(' ', concat('"', ROW_NUMBER() over(order by dtype), '"'), dtype) as col_name from #__EXP_ResultMeta) as t;
    select @ACT_column_name_dtype=string_agg(col_name, ', ') from (select concat_ws(' ', concat('"', ROW_NUMBER() over(order by dtype), '"'), dtype) as col_name from #__ACT_ResultMeta) as t;
    
    -- store results into tables with normalized column
    
    -- create temp tables
    declare @EXP_create_sql NVARCHAR(max), @ACT_create_sql NVARCHAR(max);
    SET @EXP_create_sql = concat_ws(' ', 'drop table if exists ##Expected_datarows; create table ##Expected_datarows', '(', @EXP_column_name_dtype,')');
    SET @ACT_create_sql = concat_ws(' ', 'drop table if exists ##Actual_datarows; create table ##Actual_datarows', '(', @ACT_column_name_dtype,')');
    EXEC sp_executesql @EXP_create_sql;
    EXEC sp_executesql @ACT_create_sql;
    
    -- populate data
    declare @EXP_insert_sql NVARCHAR(max), @ACT_select_sql NVARCHAR(max);

    SET @EXP_insert_sql = concat_ws(' ', 'insert into ##Expected_datarows', 'select', @EXP_column_name_alias, 'from', '##Expected');
    SET @ACT_select_sql = concat_ws(' ', 'insert into ##Actual_datarows', 'select', @ACT_column_name_alias, 'from', '##Actual');
    -- print @EXP_insert_sql;
    -- print @ACT_select_sql;
    EXEC sp_executesql @EXP_insert_sql;
    EXEC sp_executesql @ACT_select_sql;

    -- add primary key to keep the order of the datarows
    ALTER TABLE ##Expected_datarows ADD __id__ INT IDENTITY CONSTRAINT PK_Expected_datarows PRIMARY KEY CLUSTERED;
    ALTER TABLE ##Actual_datarows ADD __id__ INT IDENTITY CONSTRAINT PK_Actual_datarows PRIMARY KEY CLUSTERED;

    select * from ##Expected_datarows;
    select * from ##Actual_datarows;

    -- assert
    BEGIN TRY
            EXEC tSQLt.AssertEqualsTable ##Expected_datarows, ##Actual_datarows;
    END TRY
    BEGIN CATCH
        -- the two sets of column datatypes NOT SAME
        -- PRINT concat_ws(' ', '!EXPECTED DATA ORDER NOT MATCHED')
        SET @status_code += 16
    END CATCH 
    END
    return @status_code
END
GO
