CREATE TABLE [dbo].[IndustryType]
(
[IndustryTypeId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_IndustryType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IndustryType] ADD CONSTRAINT [PK_IndustryType] PRIMARY KEY CLUSTERED  ([IndustryTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_IndustryTypeName] ON [dbo].[IndustryType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
