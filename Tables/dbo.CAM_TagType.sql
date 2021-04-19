CREATE TABLE [dbo].[CAM_TagType]
(
[TagTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Colour] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_CAM_TagType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CAM_TagType_Archived] DEFAULT ((0)),
[IsRequiredForCoaching] [bit] NULL,
[IsExclusive] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_TagType] ADD CONSTRAINT [PK_CAM_TagType] PRIMARY KEY CLUSTERED  ([TagTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
