CREATE TABLE [dbo].[SMSSource]
(
[SMSSourceId] [int] NOT NULL,
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_SMSSource_LastOp] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_SMSSource_Arc] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SMSSource] ADD CONSTRAINT [PK_SMSSource] PRIMARY KEY CLUSTERED  ([SMSSourceId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
