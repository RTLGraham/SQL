CREATE TABLE [dbo].[VideoStatusType]
(
[VideoStatusTypeId] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_VideoStatusType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_VideoStatusType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VideoStatusType] ADD CONSTRAINT [PK_VideoStatusType] PRIMARY KEY CLUSTERED  ([VideoStatusTypeId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VideoStatusType] ADD CONSTRAINT [UN_VideoStatus_Name] UNIQUE NONCLUSTERED  ([Name]) ON [PRIMARY]
GO
