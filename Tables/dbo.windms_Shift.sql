CREATE TABLE [dbo].[windms_Shift]
(
[ShiftId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TruckId] [bigint] NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstStartTime] [datetime] NULL,
[EstEndTime] [datetime] NULL,
[ShiftDate] [datetime] NULL,
[ShiftNumber] [int] NULL,
[ArrivedDateTime] [datetime] NULL CONSTRAINT [DF__windms_Sh__Arriv__6C44C29B] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF__windms_Sh__Archi__6D38E6D4] DEFAULT ((0))
) ON [PRIMARY]
GO
