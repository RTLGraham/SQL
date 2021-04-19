CREATE TABLE [dbo].[DataDispatchErrorLog]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[Component] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Header] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataDispatchErrorLog] ADD CONSTRAINT [PK_DataDispatchErrorLog] PRIMARY KEY CLUSTERED  ([LogID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
