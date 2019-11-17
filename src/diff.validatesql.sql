DROP PROCEDURE IF EXISTS Diff.ValidateSQL
GO
create PROCEDURE Diff.ValidateSQL
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