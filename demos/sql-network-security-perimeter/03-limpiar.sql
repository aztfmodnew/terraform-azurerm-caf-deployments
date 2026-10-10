:On Error exit
IF DB_NAME() <> N'demo'
    THROW 51000, 'Connect to demo, not master.', 1;
GO
IF EXISTS (SELECT 1 FROM sys.dm_xe_database_sessions WHERE name = N'nsp_demo')
    ALTER EVENT SESSION [nsp_demo] ON DATABASE STATE = STOP;
IF EXISTS (SELECT 1 FROM sys.database_event_sessions WHERE name = N'nsp_demo')
    DROP EVENT SESSION [nsp_demo] ON DATABASE;
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'https://$(BlobHost)/events')
    DROP DATABASE SCOPED CREDENTIAL [https://$(BlobHost)/events];
GO
