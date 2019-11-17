DROP PROCEDURE IF EXISTS Checker.Uninstall
GO
CREATE PROCEDURE Checker.Uninstall
AS
BEGIN
    EXEC tSQLt.DropClass 'Checker';
END