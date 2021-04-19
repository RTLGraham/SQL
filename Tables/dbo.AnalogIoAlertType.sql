CREATE TABLE [dbo].[AnalogIoAlertType]
(
[AnalogIoAlertTypeId] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_AnalogIoAlertType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_AnalogIoAlertType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AnalogIoAlertType] ADD CONSTRAINT [PK_AnalogIoAlertType] PRIMARY KEY CLUSTERED  ([AnalogIoAlertTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AnalogIoAlertType] ADD CONSTRAINT [UN_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
