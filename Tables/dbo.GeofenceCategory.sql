CREATE TABLE [dbo].[GeofenceCategory]
(
[GeofenceCategoryId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Colour] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_GeofenceCategory_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_GeofenceCategory_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GeofenceCategory] ADD CONSTRAINT [PK_GeofenceCategory] PRIMARY KEY CLUSTERED  ([GeofenceCategoryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GeofenceCategoryName] ON [dbo].[GeofenceCategory] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
