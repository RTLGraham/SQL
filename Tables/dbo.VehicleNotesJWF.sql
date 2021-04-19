CREATE TABLE [dbo].[VehicleNotesJWF]
(
[VehicleNotesId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[TachoType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TachoVersion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Com1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Com2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CANType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EBrake] [bit] NULL,
[Cruise] [bit] NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleNotesJWF] ADD CONSTRAINT [PK_VehicleNotesJWF] PRIMARY KEY CLUSTERED  ([VehicleNotesId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
