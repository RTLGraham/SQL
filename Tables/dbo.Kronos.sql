CREATE TABLE [dbo].[Kronos]
(
[KronosId] [int] NOT NULL IDENTITY(1, 1),
[DriverIntId] [int] NOT NULL,
[KronosDate] [smalldatetime] NOT NULL,
[FirstIn] [datetime] NULL,
[FirstOut] [datetime] NULL,
[SecondIn] [datetime] NULL,
[SecondOut] [datetime] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_Kronos_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_Kronos_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Kronos] ADD CONSTRAINT [PK_Kronos] PRIMARY KEY CLUSTERED  ([KronosId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Kronos_DriverDate] ON [dbo].[Kronos] ([DriverIntId], [KronosDate]) ON [PRIMARY]
GO
