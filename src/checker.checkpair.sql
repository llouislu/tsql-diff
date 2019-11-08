DROP PROCEDURE IF EXISTS Checker.CheckPair
GO
CREATE PROCEDURE Checker.CheckPair
    @ExpectedFilePath NVARCHAR(max),
    @ActualFilePath NVARCHAR(max)
AS
BEGIN
    -- read sql file
    -- expected
    DECLARE @expected_sqlcontent TABLE (content NVARCHAR(max));
    DECLARE @expected_sqlstring NVARCHAR(max);
    insert @expected_sqlcontent
    exec Checker.LoadSQLFile @ExpectedFilePath;
    select @expected_sqlstring=content
    from @expected_sqlcontent;
    -- print(@expected_sqlstring)
    -- actual
    DECLARE @actual_sqlcontent TABLE (content NVARCHAR(max));
    DECLARE @actual_sqlstring NVARCHAR(max);
    insert @actual_sqlcontent
    exec Checker.LoadSQLFile @ActualFilePath;
    select @actual_sqlstring=content
    from @actual_sqlcontent;
    -- print(@actual_sqlstring)

    -- validate
    DECLARE @expected_validate_result int = -1;
    EXEC @expected_validate_result = Checker.ValidateSQL @expected_sqlstring;
    -- print @expected_validate_result;
    if @expected_validate_result=1
        BEGIN
            PRINT concat('Syntax Error in: ', @expected_sqlstring)
            RETURN 1
        END


    DECLARE @actual_validate_result int = -1;
    EXEC @actual_validate_result = Checker.ValidateSQL @actual_sqlstring;
    -- print @actual_validate_result;
    if @actual_validate_result=1
        BEGIN
            PRINT concat('Syntax Error in: ', @actual_sqlstring)
            RETURN 1
        END

    -- print '==================================='
    -- execute and assert
    DECLARE @status_code INT;
    exec @status_code = Checker.CheckStringPair @expected_sqlstring, @actual_sqlstring;
    return @status_code
END
GO