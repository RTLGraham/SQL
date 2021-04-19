CREATE TABLE [dbo].[Camera]
(
[CameraId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Camera_CameraId] DEFAULT (newsequentialid()),
[CameraIntId] [int] NOT NULL IDENTITY(1, 1),
[ProjectId] [int] NOT NULL,
[Serial] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LicensePlate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Camera_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_Camera_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Camera] ADD CONSTRAINT [PK_Camera] PRIMARY KEY CLUSTERED  ([CameraId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Camera_ArchivedSerial] ON [dbo].[Camera] ([Archived]) INCLUDE ([Serial]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Camera] ADD CONSTRAINT [UQ__Camera__6ADB9D16] UNIQUE NONCLUSTERED  ([CameraIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Camera] ADD CONSTRAINT [FK_Camera_Project] FOREIGN KEY ([ProjectId]) REFERENCES [dbo].[Project] ([ProjectId])
GO
