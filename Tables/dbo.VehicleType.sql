CREATE TABLE [dbo].[VehicleType]
(
[VehicleTypeID] [int] NOT NULL IDENTITY(1, 1),
[Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL,
[CustomerIntID] [int] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleType] ADD CONSTRAINT [PK_VehicleType] PRIMARY KEY CLUSTERED  ([VehicleTypeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleType] ADD CONSTRAINT [FK_VehicleType_Customer] FOREIGN KEY ([CustomerIntID]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
