CREATE TABLE [dbo].[TescoRecordType]
(
[RecordTypeId] [int] NOT NULL,
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_tescoIncidentType_Arc] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_TescoIncidentType_LastOp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TescoRecordType] ADD CONSTRAINT [PK_TescoIncidentType] PRIMARY KEY CLUSTERED  ([RecordTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
