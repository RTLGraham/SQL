CREATE TABLE [dbo].[Log]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[EventID] [int] NULL,
[Priority] [int] NOT NULL,
[Severity] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Title] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Timestamp] [datetime] NOT NULL,
[MachineName] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppDomainName] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcessID] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcessName] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ThreadName] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Win32ThreadId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [nvarchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormattedMessage] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Log] ADD CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED  ([LogID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Timestamp] ON [dbo].[Log] ([Timestamp]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
