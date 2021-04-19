CREATE TABLE [dbo].[WriteEventLog]
(
[RecordID] [bigint] NOT NULL IDENTITY(1, 1),
[StartTime] [datetime] NULL,
[EndDate] [datetime] NULL,
[ConnectionID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WriteEventLog] ADD CONSTRAINT [PK_WriteEventLog] PRIMARY KEY CLUSTERED  ([RecordID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
