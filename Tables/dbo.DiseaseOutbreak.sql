CREATE TABLE [dbo].[DiseaseOutbreak]
(
[DiseaseOutbreakId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutbreakStartDate] [datetime] NULL,
[OutbreakEndDate] [datetime] NULL,
[RegisteredBy] [uniqueidentifier] NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_DiseaseOutbreak_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_DiseaseOutbreak_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreak] ADD CONSTRAINT [PK_DiseaseOutbreak] PRIMARY KEY CLUSTERED  ([DiseaseOutbreakId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreak] WITH NOCHECK ADD CONSTRAINT [FK_DiseaseOutbreak_User] FOREIGN KEY ([RegisteredBy]) REFERENCES [dbo].[User] ([UserID])
GO
