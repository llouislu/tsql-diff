# T-SQL Diff
Compare Difference In T-SQL Queries at Runtime

![CI Status](https://travis-ci.org/llouislu/tsql-diff.svg?branch=master) ![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

## Install
1. Go to [release](https://github.com/llouislu/tsql-diff/releases) and download the latest version.
2. execute install.sql in your target database.

## Uninstall
Execute this stored procedure.
```sql
EXEC Diff.Uninstall;
```

## Usage
Please refer to the doc/examples while reading this section.

There is a `Diff` schema in your target database after you successfully installed this library.

### Compare two queries in strings
```sql
DECLARE @status_code INT;
EXEC @status_code = Diff.CompareString 'Select 1', 'Select 2';
```

### Compare two queries in files
```sql
DECLARE @status_code INT;
EXEC @status_code = Diff.Compare 'path/to/query1.sql', 'path/to/query2.sql';
```

### Compare pairs of queries in a folder
```sql
declare @status_code INT;
exec Diff.ComapreFolder @FolderPath='/root/data/t', @ModifierName='Model'
```
