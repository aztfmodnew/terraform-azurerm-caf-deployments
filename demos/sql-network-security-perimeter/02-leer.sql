:On Error exit
IF DB_NAME() <> N'demo'
    THROW 51000, 'Connect to demo, not master.', 1;
GO
SELECT SYSUTCDATETIME() AS observed_utc, DB_NAME() AS database_name;
SELECT TOP (5) object_name, CAST(event_data AS xml) AS event_data
FROM sys.fn_xe_file_target_read_file(
    N'https://$(BlobHost)/events/nsp-demo', NULL, NULL, NULL
);
GO
