CREATE TABLE [dbo].[KB_DriverGroupFolder]
(
[DriverGroupId] [uniqueidentifier] NOT NULL,
[FolderId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_DriverGroupFolder] ADD CONSTRAINT [PK_KB_DriverGroupFolder] PRIMARY KEY CLUSTERED  ([DriverGroupId], [FolderId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_DriverGroupFolder] ADD CONSTRAINT [FK_KB_DriverGroupFolder_Folder] FOREIGN KEY ([FolderId]) REFERENCES [dbo].[KB_Folder] ([FolderId])
GO
