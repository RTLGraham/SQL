CREATE TABLE [dbo].[CAM_EventTypeCreationCode]
(
[EventTypeId] [smallint] NOT NULL,
[EventType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationCodeId] [smallint] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_EventType_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CAM_EventType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_EventTypeCreationCode] ADD CONSTRAINT [PK_CAM_EventTypeCreationCode] PRIMARY KEY CLUSTERED  ([EventTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
