CREATE TABLE [dbo].[LogAPI]
(
[LogAPIId] [int] NOT NULL IDENTITY(1, 1),
[UserId] [uniqueidentifier] NULL,
[Method] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MethodParameters] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Duration] [float] NULL,
[Result] [bit] NOT NULL CONSTRAINT [DF__LogAPI__Result__5B7A294C] DEFAULT ((0)),
[ErrorMessage] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LogAPI] ADD CONSTRAINT [PK_LogAPI] PRIMARY KEY CLUSTERED  ([LogAPIId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
