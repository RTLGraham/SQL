CREATE TABLE [dbo].[RPM]
(
[RPMId] [bigint] NOT NULL,
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[CreationDateTime] [datetime] NOT NULL,
[Text] [char] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL,
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RPM] ADD CONSTRAINT [PK_RPM] PRIMARY KEY CLUSTERED  ([RPMId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RPM] ADD CONSTRAINT [FK_RPM_IVH] FOREIGN KEY ([IVHIntId]) REFERENCES [dbo].[IVH] ([IVHIntId])
GO
ALTER TABLE [dbo].[RPM] ADD CONSTRAINT [FK_RPM_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
