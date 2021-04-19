CREATE TABLE [dbo].[SMS]
(
[SMSId] [int] NOT NULL IDENTITY(1, 1),
[SMSSourceId] [int] NOT NULL CONSTRAINT [DF_SMS_Source] DEFAULT ((0)),
[SMSStatusId] [int] NOT NULL CONSTRAINT [DF_SMS_Status] DEFAULT ((0)),
[TelephoneNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SenderId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SMSMessage] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternalIntId] [int] NULL,
[SMSExternalid] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeInitiated] [datetime] NULL,
[TimeCompleted] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_SMS_LastOp] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_SMS_Arc] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SMS] ADD CONSTRAINT [FK_SMS_SMSSource] FOREIGN KEY ([SMSSourceId]) REFERENCES [dbo].[SMSSource] ([SMSSourceId])
GO
ALTER TABLE [dbo].[SMS] ADD CONSTRAINT [FK_SMS_SMSStatus] FOREIGN KEY ([SMSStatusId]) REFERENCES [dbo].[SMSStatus] ([SMSStatusId])
GO
