CREATE TABLE [dbo].[VehicleFirmware]
(
[VehicleFirmwareId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[BaseActiveInd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Version] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Website] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WebsiteChangeInd] [bit] NULL,
[Network] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkChangeInd] [bit] NULL,
[Com1] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Com1ChangeInd] [bit] NULL,
[Com2] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Com2ChangeInd] [bit] NULL,
[CanType] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CanTypeChangeInd] [bit] NULL,
[Options] [varchar] (26) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionsChangeInd] [bit] NULL,
[TestVersion] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleFirmware] ADD CONSTRAINT [PK_VehicleFirmware] PRIMARY KEY CLUSTERED  ([VehicleFirmwareId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleFirmware_VehicleBaseActive] ON [dbo].[VehicleFirmware] ([VehicleId], [BaseActiveInd]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleFirmware] WITH NOCHECK ADD CONSTRAINT [FK_VehicleFirmware_VehicleId] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
