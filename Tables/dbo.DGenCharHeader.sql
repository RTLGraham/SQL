CREATE TABLE [dbo].[DGenCharHeader]
(
[DgenId] [int] NOT NULL,
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
[SweetSpotLow] [int] NULL,
[SweetSpotHigh] [int] NULL,
[OverRev] [int] NULL,
[TotalTime] [int] NULL,
[TotalDistance] [float] NULL,
[TotalFuel] [float] NULL,
[RPM100Time] [int] NULL,
[RPM100Distance] [float] NULL,
[RPM100Fuel] [float] NULL,
[RPM0Time] [int] NULL,
[RPM0Distance] [float] NULL,
[RPM0Fuel] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DGenCharHeader] ADD CONSTRAINT [PK_DGenCharHeader] PRIMARY KEY CLUSTERED  ([DgenId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
