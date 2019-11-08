DROP PROCEDURE IF EXISTS Checker.ValidateSQL
GO
create PROCEDURE Checker.ValidateSQL
    @QueryString NVARCHAR(max)
AS
BEGIN
    BEGIN TRY
    DECLARE @SQL NVARCHAR(max)
    SET @SQL = concat('set parseonly on;', @QueryString);
    exec(@SQL);
END TRY

BEGIN CATCH
--     invalid
        PRINT concat_ws(' ', 'invalid Query', @QueryString)
        RETURN 1;
END CATCH
    -- valid
    RETURN 0
END
GO