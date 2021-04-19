CREATE TABLE [dbo].[KB_FileFolder]
(
[FileId] [int] NOT NULL,
[FolderId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_FileFolder] ADD CONSTRAINT [PK_KB_FileFolder] PRIMARY KEY CLUSTERED  ([FileId], [FolderId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_FileFolder] ADD CONSTRAINT [FK_KB_FileFolder_File] FOREIGN KEY ([FileId]) REFERENCES [dbo].[KB_File] ([FileId])
GO
ALTER TABLE [dbo].[KB_FileFolder] ADD CONSTRAINT [FK_KB_FileFolder_Folder] FOREIGN KEY ([FolderId]) REFERENCES [dbo].[KB_Folder] ([FolderId])
GO
