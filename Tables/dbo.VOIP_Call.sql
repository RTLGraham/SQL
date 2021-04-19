CREATE TABLE [dbo].[VOIP_Call]
(
[CallId] [int] NOT NULL IDENTITY(1, 1),
[CallSourceId] [int] NOT NULL CONSTRAINT [DF_VOIP_Call_CallSource] DEFAULT ((0)),
[CallStatusId] [int] NOT NULL CONSTRAINT [DF_VOIP_Call_CallStatus] DEFAULT ((0)),
[TelephoneNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlaybackMessage] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternalIntId] [int] NULL,
[ExternalUniqueId] [uniqueidentifier] NULL,
[ExternalStringId] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CallSid] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeInitiated] [datetime] NULL,
[TimeCompleted] [datetime] NULL,
[CallDuration] [int] NULL,
[CallAttempts] [int] NOT NULL CONSTRAINT [DF_VOIP_Call_CallAttempts] DEFAULT ((0)),
[Details] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VOIP_Call_LastOp] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VOIP_Call_Arc] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOIP_Call] ADD CONSTRAINT [PK__VOIP_Cal__5180CFAA6CE5B3DF] PRIMARY KEY CLUSTERED  ([CallId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOIP_Call] ADD CONSTRAINT [FK_VOIP_Call_CallSource] FOREIGN KEY ([CallSourceId]) REFERENCES [dbo].[VOIP_CallSource] ([CallSourceId])
GO
ALTER TABLE [dbo].[VOIP_Call] ADD CONSTRAINT [FK_VOIP_Call_CallStatus] FOREIGN KEY ([CallStatusId]) REFERENCES [dbo].[VOIP_CallStatus] ([CallStatusId])
GO
