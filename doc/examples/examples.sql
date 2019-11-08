-- check file pairs in a folder
declare @status_code INT;
exec Checker.CheckFolder @FolderPath='/root/data/t', @ModifierName='Model'

