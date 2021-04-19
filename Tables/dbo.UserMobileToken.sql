CREATE TABLE [dbo].[UserMobileToken]
(
[UserMobileTokenId] [int] NOT NULL IDENTITY(1, 1),
[UserId] [uniqueidentifier] NOT NULL,
[MobileToken] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_UserMobileToken_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_UserMobileToken_Archived] DEFAULT ((0)),
[DeviceId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserMobileToken] ADD CONSTRAINT [PK_UserMobileToken] PRIMARY KEY CLUSTERED  ([UserMobileTokenId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
