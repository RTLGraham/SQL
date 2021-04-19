CREATE TABLE [dbo].[DiseaseOutbreakUser]
(
[DiseaseOutbreakId] [int] NOT NULL,
[UserId] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreakUser] ADD CONSTRAINT [PK_DiseaseOutbreakUser] PRIMARY KEY CLUSTERED  ([DiseaseOutbreakId], [UserId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreakUser] ADD CONSTRAINT [FK_DiseaseOutbreakUser_DiseaseOutbreak] FOREIGN KEY ([DiseaseOutbreakId]) REFERENCES [dbo].[DiseaseOutbreak] ([DiseaseOutbreakId])
GO
ALTER TABLE [dbo].[DiseaseOutbreakUser] ADD CONSTRAINT [FK_DiseaseOutbreakUser_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserID])
GO
