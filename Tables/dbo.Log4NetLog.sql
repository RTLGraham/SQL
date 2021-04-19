CREATE TABLE [dbo].[Log4NetLog]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NULL,
[Thread] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Level] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Logger] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Log4NetLog] ADD CONSTRAINT [PK_Log4NetLog] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
