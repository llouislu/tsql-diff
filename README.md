# T-SQL Diff
Compare Difference In T-SQL Queries at Runtime

![CI Status](https://travis-ci.org/llouislu/tsql-diff.svg?branch=master) ![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

## Install
1. Run the following SQL in your target database
```sql
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 1
RECONFIGURE;
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;
GO
```
2. Download [tSQLt](http://tsqlt.org/download/tsqlt/) and follow the install [guide](https://tsqlt.org/user-guide/quick-start/).
3. Go to [release](https://github.com/llouislu/tsql-diff/releases) and download the latest **Release** version.
4. execute install.sql in your target database.

## Uninstall
Execute this stored procedure.
```sql
EXEC Diff.Uninstall;
```

## Usage
Please refer to the doc/examples while reading this section.

There is a `Diff` schema in your target database after you successfully installed this library.

### Compare two queries in strings
#### Syntax
```sql
Diff.CompareString
    @EXP_QueryString NVARCHAR(max),
    -- expected query string 
    @ACT_QueryString NVARCHAR(max),
    -- actual query string
    @ExplicitColumnOrder TINYINT = 1,
    -- optional, set default value 1 to compare column order
    @ExplicitColumnName TINYINT = 1,
    -- optional, set default value 1 to compare column name(s)
    @CompareData TINYINT = 1
    -- optional, set default value 1 to reorder data rows and compare the difference
```
#### Output
- An `INT`, a sum of error values
- Detailed difference in log
#### Example
```sql
DECLARE @status_code INT;
EXEC @status_code = Diff.CompareString 'Select 1', 'Select 2';
```

### Compare two queries in files
#### Syntax
```sql
Diff.Compare
    @ExpectedFilePath NVARCHAR(max),
    -- file path of expected query
    @ActualFilePath NVARCHAR(max),
    -- file path of actual query
    @ExplicitColumnOrder TINYINT = 1,
    -- optional, set default value 1 to compare column order
    @ExplicitColumnName TINYINT = 1,
    -- optional, set default value 1 to compare column name(s)
    @CompareData TINYINT = 1
    -- optional, set default valueet 1 to reorder data rows and compare the difference
```
#### Output
- An `INT`, a sum of error values
- Detailed difference in log
#### Example
```sql
DECLARE @status_code INT;
EXEC @status_code = Diff.Compare 'path/to/query1.sql', 'path/to/query2.sql';
```

### Compare pairs of queries in a folder
#### Syntax
```sql
Diff.CompareFolder
    @FolderPath NVARCHAR(1024) = N'/root/data/t',
    -- location of a folder where T-SQL files are stored
    -- accepts filepaths on Windows and Linux
    @ModifierName NVARCHAR(32) = N'Model',
    -- a filename suffix in  identifying the current file as an anchor/master/standard/expected query
    -- e.g. In the filename 'q01Model.sql', 'Model' indicates the file is marked as correct.
    @FileSuffix NVARCHAR(8) = N'.sql'
    -- a filename extension of T-SQL files
```
#### Output
- Detailed difference in log
#### Example
```sql
declare @status_code INT;
exec Diff.ComapreFolder @FolderPath='/test', @ModifierName='Model'
```

### Error Values
| value | error                                      |
|:-----:|--------------------------------------------|
| 1     | runtime error or no valid select statement |
| 2     | expected column datatype(s) not matched    |
| 4     | column order not matched                   |
| 8     | column names not matched                   |
| 16    | data row not matched                       |

### FAQ
Q: Why `Diff.CompareFolder` finds nothing in a folder on Windows?

A: Please grant read access of the folder to the user group `Authenticated Users`.

### Limitations

- T-SQL Diff only receives the first `SELECT` statement as input to compare

- `WITH` statements (e.g. cte) in `SELECT` are not supported

- Custom datatypes defined by CLR are not supported
