:On Error exit
IF DB_NAME() <> N'demo'
    THROW 51000, 'Connect to demo, not master.', 1;
GO
IF EXISTS (SELECT 1 FROM sys.database_event_sessions WHERE name = N'nsp_demo')
    THROW 51001, 'nsp_demo already exists. Clean up explicitly before preparing again.', 1;
GO
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'##MS_DatabaseMasterKey##')
    CREATE MASTER KEY;
GO
CREATE DATABASE SCOPED CREDENTIAL [https://$(BlobHost)/events]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE', SECRET = '$(ContainerSas)';
GO
CREATE EVENT SESSION [nsp_demo] ON DATABASE
ADD EVENT sqlserver.sql_batch_starting
ADD TARGET package0.event_file
(SET filename = N'https://$(BlobHost)/events/nsp-demo.xel',
      max_file_size = 5, max_rollover_files = 2)
WITH (MAX_DISPATCH_LATENCY = 1 SECONDS, STARTUP_STATE = OFF);
GO
ALTER EVENT SESSION [nsp_demo] ON DATABASE STATE = START;
GO
SELECT N'Azure Tour: synthetic event for the outbound demo' AS demo_marker;
GO
WAITFOR DELAY '00:00:03';
ALTER EVENT SESSION [nsp_demo] ON DATABASE STATE = STOP;
GO
