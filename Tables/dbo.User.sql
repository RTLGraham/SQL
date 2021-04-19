CREATE TABLE [dbo].[User]
(
[UserID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_User_UserID] DEFAULT (newid()),
[Name] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_User_Archived] DEFAULT ((0)),
[Email] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surname] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [uniqueidentifier] NULL,
[ExpiryDate] [datetime] NULL,
[IsADSyncDisabled] [bit] NULL CONSTRAINT [DF__User__IsADSyncDi__05706318] DEFAULT ((0)),
[PasswordHash] [varbinary] (64) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[User] ADD CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED  ([UserID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
