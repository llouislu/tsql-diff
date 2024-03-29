DROP PROCEDURE IF EXISTS Diff.LoadSQLFile
GO
CREATE PROCEDURE Diff.LoadSQLFile
    @FilePath NVARCHAR(max)
AS
BEGIN
    DECLARE @command NVARCHAR(max), @FileContent NVARCHAR(max);
    set @command = N'SELECT @sqlFromFile=BulkColumn FROM OPENROWSET(BULK ''' + @FilePath + ''',SINGLE_CLOB) ROW_SET';
    EXEC sp_executesql @command, N'@sqlFromFile NVARCHAR(MAX) OUTPUT', @sqlFromFile=@FileContent OUTPUT;
    select @FileContent
END
GO