CREATE TABLE [dbo].[UserSession]
(
[SessionID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_UserSession_SessionID] DEFAULT (newid()),
[UserID] [uniqueidentifier] NOT NULL,
[IsLoggedIn] [bit] NULL CONSTRAINT [DF_UserSession_IsLoggedIn] DEFAULT ((0)),
[LastOperation] [datetime] NULL CONSTRAINT [DF_UserSession_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserSession] ADD CONSTRAINT [PK_UserSession] PRIMARY KEY CLUSTERED  ([SessionID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserSession_UID] ON [dbo].[UserSession] ([UserID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserSession_UserId] ON [dbo].[UserSession] ([UserID]) INCLUDE ([SessionID], [IsLoggedIn], [LastOperation]) ON [PRIMARY]
GO
