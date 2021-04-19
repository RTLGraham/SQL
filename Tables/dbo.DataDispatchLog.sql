CREATE TABLE [dbo].[DataDispatchLog]
(
[LogID] [int] NOT NULL IDENTITY(1, 1),
[DispatchType] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DataDispatchLog] ADD CONSTRAINT [PK_DataDispatchLog] PRIMARY KEY CLUSTERED  ([LogID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
