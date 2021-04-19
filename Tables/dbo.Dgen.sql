CREATE TABLE [dbo].[Dgen]
(
[DgenId] [bigint] NOT NULL,
[CustomerIntId] [int] NOT NULL,
[VehicleIntId] [int] NOT NULL,
[DriverIntId] [int] NOT NULL,
[DgenDateTime] [datetime] NOT NULL,
[DgenIndexId] [smallint] NOT NULL,
[DgenTypeId] [smallint] NOT NULL,
[AccumSeqNbr] [int] NOT NULL,
[Payload] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DgenCount] [int] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NOT NULL,
[ProcessInd] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Dgen] ADD CONSTRAINT [PK_Dgen] PRIMARY KEY CLUSTERED  ([DgenId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DGen_TypeProcessInd] ON [dbo].[Dgen] ([DgenTypeId], [DgenIndexId], [ProcessInd]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DGen_VehicleIntId] ON [dbo].[Dgen] ([VehicleIntId], [DgenDateTime]) INCLUDE ([DgenId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
