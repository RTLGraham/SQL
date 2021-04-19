CREATE TABLE [dbo].[GroupDataType]
(
[GroupDataTypeId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupDataType] ADD CONSTRAINT [PK_GroupDataType] PRIMARY KEY CLUSTERED  ([GroupDataTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
