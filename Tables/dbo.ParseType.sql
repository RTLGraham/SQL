CREATE TABLE [dbo].[ParseType]
(
[ParseTypeId] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delimiter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
