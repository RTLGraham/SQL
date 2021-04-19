CREATE TABLE [dbo].[Site]
(
[SiteId] [int] NOT NULL IDENTITY(1, 1),
[SiteTypeId] [int] NOT NULL,
[CustomerIntId] [int] NOT NULL,
[SiteNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Radius] [float] NULL,
[Lon] [float] NULL,
[Lat] [float] NULL,
[StopDuration] [int] NULL,
[CreationDate] [datetime] NULL CONSTRAINT [DF_Site_CreationDate] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_Site_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_Site_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Site] ADD CONSTRAINT [PK_Site] PRIMARY KEY CLUSTERED  ([SiteId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Site] ADD CONSTRAINT [FK_Site_SiteType] FOREIGN KEY ([SiteTypeId]) REFERENCES [dbo].[SiteType] ([SiteTypeId])
GO
