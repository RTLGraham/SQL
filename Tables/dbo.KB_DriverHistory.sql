CREATE TABLE [dbo].[KB_DriverHistory]
(
[DriverHistoryId] [int] NOT NULL IDENTITY(1, 1),
[DriverIntId] [int] NOT NULL,
[FileId] [int] NOT NULL,
[AccessDateTime] [datetime] NULL,
[ViewedDuration] [int] NULL,
[LastOperation] [smalldatetime] NULL,
[isAcknowledged] [bit] NULL,
[AssessDateTime] [datetime] NULL,
[isAssessed] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_DriverHistory] ADD CONSTRAINT [PK_KB_DriverHistory] PRIMARY KEY CLUSTERED  ([DriverHistoryId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_DriverHistory] ADD CONSTRAINT [FK_KB_DriverHistory_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[KB_DriverHistory] ADD CONSTRAINT [FK_KB_DriverHistory_File] FOREIGN KEY ([FileId]) REFERENCES [dbo].[KB_File] ([FileId])
GO
