CREATE TABLE [dbo].[VehicleCreationCode]
(
[VehicleCreationCodeId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_VehicleCreationCode_VehicleCreationCodeId] DEFAULT (newid()),
[VehicleId] [uniqueidentifier] NULL,
[CreationCodeId] [smallint] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleCreationCode_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleCreationCode_Archived] DEFAULT ((0)),
[CreationCodeStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationCodeHighIsOff] [bit] NULL CONSTRAINT [DF_VehiclesCreationCode_CreationCodeHighIsOff] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleCreationCode] ADD CONSTRAINT [PK_VehicleCreationCode] PRIMARY KEY CLUSTERED  ([VehicleCreationCodeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleCreationCode_Vehicle] ON [dbo].[VehicleCreationCode] ([VehicleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleCreationCode] WITH NOCHECK ADD CONSTRAINT [FK_VehicleCreationCode_CreationCode] FOREIGN KEY ([CreationCodeId]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
ALTER TABLE [dbo].[VehicleCreationCode] ADD CONSTRAINT [FK_VehicleCreationCode_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
