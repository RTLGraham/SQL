CREATE TABLE [dbo].[WebsiteSkin]
(
[WebsiteSkinId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AspxPage] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_WebsiteSkin_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_WebsiteSkin_Archived] DEFAULT ((0)),
[CSSFolder] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebsiteSkin] ADD CONSTRAINT [PK_WebsiteSkin] PRIMARY KEY CLUSTERED  ([WebsiteSkinId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
