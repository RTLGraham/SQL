CREATE TABLE [dbo].[UserFailedLogin]
(
[UserFailedLoginID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserFailedLogin] ADD CONSTRAINT [PK_UserFailedLogin] PRIMARY KEY CLUSTERED  ([UserFailedLoginID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
