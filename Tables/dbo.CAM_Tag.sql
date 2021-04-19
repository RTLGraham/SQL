CREATE TABLE [dbo].[CAM_Tag]
(
[TagId] [int] NOT NULL IDENTITY(1, 1),
[TagTypeId] [int] NOT NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOrder] [int] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_CAM_Tag_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CAM_Tag_Archived] DEFAULT ((0)),
[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_Tag] ADD CONSTRAINT [PK_CAM_Tag] PRIMARY KEY CLUSTERED  ([TagId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_Tag] ADD CONSTRAINT [FK_CAM_Tag_CAM_TagType] FOREIGN KEY ([TagTypeId]) REFERENCES [dbo].[CAM_TagType] ([TagTypeId])
GO
