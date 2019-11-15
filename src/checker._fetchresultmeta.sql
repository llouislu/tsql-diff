drop PROCEDURE if EXISTS Checker.Private_FetchResultMetaData
GO
CREATE PROCEDURE Checker.Private_FetchResultMetaData
        -- show the result table structure of the first select statement in the query string
        -- returned table in table #ResultStructure
        -- if empty, means the whole query does not contain a select statement
        @QueryString NVARCHAR(max)
AS
BEGIN
        IF OBJECT_ID('tempdb..##ResultStructure') IS NOT NULL DROP TABLE ##ResultStructure;
        create table ##ResultStructure
        (
                is_hidden bit NOT NULL
,
                column_ordinal int NOT NULL
,
                name sysname NULL
,
                is_nullable bit NOT NULL
,
                system_type_id int NOT NULL
,
                system_type_name nvarchar(256) NULL
,
                max_length smallint NOT NULL
,
                precision tinyint NOT NULL
,
                scale tinyint NOT NULL
,
                collation_name sysname NULL
,
                user_type_id int NULL
,
                user_type_database sysname NULL
,
                user_type_schema sysname NULL
,
                user_type_name sysname NULL
,
                assembly_qualified_type_name nvarchar(4000)
,
                xml_collection_id int NULL
,
                xml_collection_database sysname NULL
,
                xml_collection_schema sysname NULL
,
                xml_collection_name sysname NULL
,
                is_xml_document bit NOT NULL
,
                is_case_sensitive bit NOT NULL
,
                is_fixed_length_clr_type bit NOT NULL
,
                source_server sysname NULL
,
                source_database sysname NULL
,
                source_schema sysname NULL
,
                source_table sysname NULL
,
                source_column sysname NULL
,
                is_identity_column bit NULL
,
                is_part_of_unique_key bit NULL
,
                is_updateable bit NULL
,
                is_computed_column bit NULL
,
                is_sparse_column_set bit NULL
,
                ordinal_in_order_by_list smallint NULL
,
                order_by_list_length smallint NULL
,
                order_by_is_descending smallint NULL
,
                tds_type_id int NOT NULL
,
                tds_length int NOT NULL
,
                tds_collation_id int NULL
,
                tds_collation_sort_id tinyint NULL
        );
        BEGIN TRY
        INSERT INTO ##ResultStructure
        EXEC sp_describe_first_result_set @QueryString; 
        END TRY  
        BEGIN CATCH  
        END CATCH; 


        -- anonymous column(name = NULL), name them
        UPDATE ##ResultStructure
        SET name = N'__anonymous_column__'
        WHERE name IS NULL;
        
        -- return
        SELECT *
        FROM ##ResultStructure
END
GO