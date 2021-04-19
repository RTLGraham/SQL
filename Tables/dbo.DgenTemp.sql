CREATE TABLE [dbo].[DgenTemp]
(
[DgenId] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerIntId] [int] NOT NULL,
[VehicleIntId] [int] NOT NULL,
[DriverIntId] [int] NOT NULL,
[DgenDateTime] [datetime] NOT NULL,
[DgenIndexId] [smallint] NOT NULL,
[DgenTypeId] [smallint] NOT NULL,
[AccumSeqNbr] [int] NOT NULL,
[Payload] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DgenCount] [int] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Dgen_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL,
[ProcessInd] [bit] NULL
) ON [PRIMARY]
GO
