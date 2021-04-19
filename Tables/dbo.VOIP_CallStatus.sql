CREATE TABLE [dbo].[VOIP_CallStatus]
(
[CallStatusId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VOIP_CallStatus_LastOp] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VOIP_CallStatus_Arc] DEFAULT ((0)),
[APIDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Significance] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOIP_CallStatus] ADD CONSTRAINT [PK_VOIP_CallStatus] PRIMARY KEY CLUSTERED  ([CallStatusId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
