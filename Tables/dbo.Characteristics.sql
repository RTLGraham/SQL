CREATE TABLE [dbo].[Characteristics]
(
[CharId] [int] NOT NULL,
[Tag] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMEI] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenReason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenDateTime] [datetime] NULL,
[CloseReason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CloseDateTime] [datetime] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[AccumSeq] [bigint] NULL,
[NumRows] [int] NULL,
[NumCols] [int] NULL,
[CharMatrixId] [int] NULL,
[CustomerIntId] [int] NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Characteristics] ADD CONSTRAINT [PK_Characteristics] PRIMARY KEY CLUSTERED  ([CharId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Characteristics_VehicleIntId_OpenClose] ON [dbo].[Characteristics] ([VehicleIntId], [OpenDateTime], [CloseDateTime]) ON [PRIMARY]
GO
