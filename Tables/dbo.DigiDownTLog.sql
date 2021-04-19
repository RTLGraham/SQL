CREATE TABLE [dbo].[DigiDownTLog]
(
[DigiDownTLogId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[FileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileTimeStamp] [datetime] NULL,
[FTAUploadId] [int] NULL,
[Succeeded] [bit] NULL,
[Reason] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UploadDateTime] [datetime] NULL,
[DriverIntId] [int] NULL,
[SmartAnalID] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SmartAnalResponse] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessInd] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DigiDownTLog_Driver] ON [dbo].[DigiDownTLog] ([DriverIntId], [FileTimeStamp], [Succeeded]) INCLUDE ([DigiDownTLogId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DigiDownTLog_Vehicle] ON [dbo].[DigiDownTLog] ([VehicleIntId], [FileTimeStamp], [Succeeded]) INCLUDE ([DigiDownTLogId]) ON [PRIMARY]
GO
