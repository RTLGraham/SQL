CREATE TABLE [dbo].[CustomerGeofenceGroup]
(
[CustomerGeofenceGroupId] [int] NOT NULL IDENTITY(1, 1),
[CustomerIntId] [int] NULL,
[GeofenceGroupId] [uniqueidentifier] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CustomerGeofenceGroup_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CustomerGeofenceGroup_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerGeofenceGroup] ADD CONSTRAINT [PK_CustomerGeofenceGroup] PRIMARY KEY CLUSTERED  ([CustomerGeofenceGroupId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerGeofenceGroup] WITH NOCHECK ADD CONSTRAINT [FK_CustomerGeofenceGroup_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
