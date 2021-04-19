CREATE TABLE [dbo].[ParseDef]
(
[ParseDefId] [int] NOT NULL IDENTITY(1, 1),
[ParseType] [int] NULL,
[Sequence] [smallint] NULL,
[Start] [smallint] NULL,
[Len] [smallint] NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
