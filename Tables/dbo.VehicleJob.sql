CREATE TABLE [dbo].[VehicleJob]
(
[VehicleJobId] [int] NOT NULL IDENTITY(1, 1),
[IVHId] [uniqueidentifier] NOT NULL,
[UnitProperty] [binary] (2) NOT NULL,
[Job] [binary] (1024) NULL,
[StatusInd] [tinyint] NOT NULL CONSTRAINT [DF_VehicleJob_Status] DEFAULT ((0)),
[CreatedDate] [smalldatetime] NULL CONSTRAINT [DF_VehicleJob_Created] DEFAULT (getdate()),
[ResponseDate] [smalldatetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleJob_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleJob] ADD CONSTRAINT [PK_VehicleJob] PRIMARY KEY CLUSTERED  ([VehicleJobId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleJob] ADD CONSTRAINT [FK_VehicleJob_IVH] FOREIGN KEY ([IVHId]) REFERENCES [dbo].[IVH] ([IVHId])
GO
