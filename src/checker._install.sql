-- check if tSQLt is installed
declare @tsql_installed INT;
select @tsql_installed=1 from sys.schemas where name='tSQLt'
if @tsql_installed=0
BEGIN
    print 'Please install tSQLt first!!!'
    RETURN
END

-- install Checker
DROP SCHEMA if EXISTS Checker
GO
CREATE SCHEMA Checker
GO

-- vendor tables
DROP TABLE IF EXISTS Checker.ERROR;
CREATE TABLE Checker.ERROR (id INT PRIMARY KEY IDENTITY(1,1), statusCode INT, action NVARCHAR(MAX), message NVARCHAR(MAX));
INSERT INTO Checker.ERROR (statusCode, [action], [message]) VALUES
(1, 'checkerstringpair', N'No "SELECT" statement in query'),
(2, 'checkerstringpair', N'EXPECTED COLUMN DATATYPE(S) NOT MATCHED'),
(4, 'checkerstringpair', N'COLUMN ORDER NOT MATCHED'),
(8, 'checkerstringpair', N'COLUMN NAMES NOT MATCHED'),
(16, 'checkerstringpair', N'COLUMN DATA ROW ORDER NOT MATCHED');