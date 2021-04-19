CREATE TABLE [dbo].[LEO_Application]
(
[ApplicationId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Appli__Archi__62DB53F2] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__LEO_Appli__LastO__63CF782B] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Application] ADD CONSTRAINT [PK_LEO_Application] PRIMARY KEY CLUSTERED  ([ApplicationId]) ON [PRIMARY]
GO
