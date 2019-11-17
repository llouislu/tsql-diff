DROP PROCEDURE IF EXISTS Diff.CompareFolder
GO
CREATE PROCEDURE Diff.CompareFolder
    @FolderPath NVARCHAR(1024) = N'/root/data/t',
    @ModifierName NVARCHAR(32) = N'Model',
    @FileSuffix NVARCHAR(8) = N'.sql'
AS
BEGIN
SET NOCOUNT ON;
-- get OS info and set file path delimiter
--https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-host-info-transact-sql?view=sql-server-ver15#examples
DECLARE @OS NVARCHAR(256), @PATHDELIMITER NVARCHAR(1);
SELECT @OS=host_platform
FROM sys.dm_os_host_info;

if @OS='Windows'
    set @PATHDELIMITER = N'\\';
ELSE
    set @PATHDELIMITER = N'/';

print CONCAT_WS(' ', 'T-SQL Diff running on', @OS, 'with');
declare @version NVARCHAR(max), @clrversion NVARCHAR(max), @sqlversion NVARCHAR(max), @Sqlbuild NVARCHAR(max), @sqledition NVARCHAR(max);
select @version=Version, @clrversion=ClrVersion, @sqlversion=SqlVersion, @Sqlbuild=SqlBuild, @sqledition=SqlEdition from tSQLt.Info();
print concat_ws(' ', 'tSQLt version:', @version, 'ClrVersion:', @clrversion, 'SqlVersion:', @sqlversion, 'SqlBuild:', @Sqlbuild, 'SqlEdition:', @sqledition)
print ''

print CONCAT_WS(' ', 'searching pairs in','"', @FolderPath, '"');
-- iterate files in folder, non-recursive
DECLARE @FilesInPath TABLE (name NVARCHAR(260),
    depth int,
    isFile int);
INSERT INTO @FilesInPath
-- path, depth(0=indefinite), file-inclusive[0=folders only, 1=folders+files)
EXEC master.sys.xp_dirtree @FolderPath, 1, 1;

DECLARE @Cursor CURSOR;
DECLARE @FileName NVARCHAR(260);
BEGIN
    DECLARE @IsFile INT
    DECLARE @FileNamePattern NVARCHAR(max) = CONCAT(N'%', @ModifierName, @FileSuffix)
    SET @Cursor = CURSOR FOR
    SELECT name
    FROM @FilesInPath
    WHERE isFile=1 and name like @FileNamePattern
    ORDER BY name;

    OPEN @Cursor
    FETCH NEXT FROM @Cursor
    INTO @FileName

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '============================'
        -- read file here
        -- get basename
        DECLARE @FileBaseName NVARCHAR(260)
        SET @FileBaseName = substring(@FileName, 0, len(@FileName) - charindex('.', reverse(@FileName)) + 1)
        -- PRINT @FileBaseName
        -- remove suffix like 'Model'
        DECLARE @StemName NVARCHAR(260)
        SET @StemName = REPLACE(@FileBaseName, @ModifierName, '')
        -- stem name
        -- PRINT @StemName

        DECLARE @ExpectedSQLFilePath NVARCHAR(max), @ActualSQLFilePath NVARCHAR(max)
        --expected sql fullpath
        SET @ExpectedSQLFilePath = CONCAT_WS(@PATHDELIMITER, @FolderPath, @FileName)
        SET @ActualSQLFilePath = CONCAT_WS(@PATHDELIMITER, @FolderPath, @StemName)
        --actual sql fullpath
        SET @ActualSQLFilePath = CONCAT(@ActualSQLFilePath, @FileSuffix)

        -- output file paths
        PRINT @ExpectedSQLFilePath
        PRINT @ActualSQLFilePath

        -- -- check if exists
        -- DECLARE @File_Exists INT;
        -- EXEC master.sys.xp_fileexist @ExpectedSQLFilePath, @File_Exists OUTPUT;
        -- -- go to next file if not exists
        -- IF @File_Exists=0
        --     BEGIN
        --     PRINT concat_ws(' ', @File_Exists, 'does not exist! Skipped.')
        --     FETCH NEXT FROM @Cursor
        --             INTO @FileName
        --     CONTINUE
        -- END
        -- EXEC master.sys.xp_fileexist @ActualSQLFilePath, @File_Exists OUTPUT
        -- -- go to next file if not exists
        -- IF @File_Exists=0
        --             BEGIN
        --     PRINT concat_ws(' ', @File_Exists, 'does not exist! Skipped.')
        --     FETCH NEXT FROM @Cursor
        --                     INTO @FileName
        --     CONTINUE
        -- END
       
        -- load file and execute them
        DECLARE @status int = 0;
        exec @status = Diff.Compare @ExpectedSQLFilePath, @ActualSQLFilePath;
        print concat_ws(' ', 'status code:', @status)
        IF @status=0
        BEGIN
            PRINT 'PASS' + char(10) + char(10)
        END
        IF @status<>0
        BEGIN
            DECLARE @msg NVARCHAR(max) = '';
            IF @status & 1 <> 0
                PRINT 'RUNTIME ERROR OR NO VALID SELECT STATEMENT'
            IF @status & 2 <> 0
                PRINT 'EXPECTED COLUMN DATATYPE(S) NOT MATCHED'
            IF @status & 4 <> 0
                set @msg += '[err4] column order not matched' + char(10)
            IF @status & 8 <> 0
                set @msg += '[err8] column names not matched' + char(10)
            IF @status & 16 <> 0
                set @msg += '[err16] data row not matched'  + char(10)
            PRINT (@msg);
            PRINT '';

            -- skip and go to next pair
            -- FETCH NEXT FROM @Cursor
            -- INTO @FileName
            -- CONTINUE
        END

        FETCH NEXT FROM @Cursor INTO @FileName
    END;

    CLOSE @Cursor ;
    DEALLOCATE @Cursor;
END
END;