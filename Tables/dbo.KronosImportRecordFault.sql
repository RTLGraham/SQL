CREATE TABLE [dbo].[KronosImportRecordFault]
(
[KronosImportRecordFaultId] [int] NOT NULL IDENTITY(1, 1),
[KronosImportId] [int] NOT NULL,
[DriverPersonalNr] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordDate] [datetime] NOT NULL,
[FirstIn] [datetime] NULL,
[FirstOut] [datetime] NULL,
[SecondIn] [datetime] NULL,
[SecondOut] [datetime] NULL,
[SecondsWorked] [int] NULL,
[AbsenseReason] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondsAbsent] [int] NULL,
[DepotName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_KronosImportRecordFault_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_KronosImportRecordFault_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosImportRecordFault] ADD CONSTRAINT [PK_KronosImportRecordFault] PRIMARY KEY CLUSTERED  ([KronosImportRecordFaultId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosImportRecordFault] ADD CONSTRAINT [FK_KronosImportRecordFault_KronosImport] FOREIGN KEY ([KronosImportId]) REFERENCES [dbo].[KronosImport] ([KronosImportId])
GO
