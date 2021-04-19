CREATE TABLE [dbo].[DiseaseOutbreakObject]
(
[DiseaseOutbreakObjectId] [int] NOT NULL IDENTITY(1, 1),
[DiseaseOutbreakId] [int] NOT NULL,
[ObjectText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Angle] [float] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_DiseaseOutbreakObject_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_DiseaseOutbreakObject_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreakObject] ADD CONSTRAINT [PK_DiseaseOutbreakObject] PRIMARY KEY CLUSTERED  ([DiseaseOutbreakObjectId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreakObject] WITH NOCHECK ADD CONSTRAINT [FK_DiseaseOutbreakObject_Id] FOREIGN KEY ([DiseaseOutbreakId]) REFERENCES [dbo].[DiseaseOutbreak] ([DiseaseOutbreakId])
GO
