CREATE TABLE [dbo].[GeofenceType]
(
[GeofenceTypeId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_GeofenceType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GeofenceType] ADD CONSTRAINT [PK_GeofenceType] PRIMARY KEY CLUSTERED  ([GeofenceTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GeofenceType] ON [dbo].[GeofenceType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
