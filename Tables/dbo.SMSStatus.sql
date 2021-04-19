CREATE TABLE [dbo].[SMSStatus]
(
[SMSStatusId] [int] NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_SMSStatus_LastOp] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_SMSStatus_Arc] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SMSStatus] ADD CONSTRAINT [PK_SMSStatus] PRIMARY KEY CLUSTERED  ([SMSStatusId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
