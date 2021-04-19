CREATE TABLE [dbo].[WKD_WorkStateType]
(
[WorkStateTypeId] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_WKD_WorkStateType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_WKD_WorkStateType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkStateType] ADD CONSTRAINT [PK_WKD_WorkStateType] PRIMARY KEY CLUSTERED  ([WorkStateTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkStateType] ADD CONSTRAINT [UN_WKD_WorkStateType_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
