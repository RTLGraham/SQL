CREATE TABLE [dbo].[ChartType]
(
[ChartTypeId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_ChartType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_ChartType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartType] ADD CONSTRAINT [PK_ChartType] PRIMARY KEY CLUSTERED  ([ChartTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ChartTypeName] ON [dbo].[ChartType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
