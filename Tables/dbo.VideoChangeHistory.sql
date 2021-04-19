CREATE TABLE [dbo].[VideoChangeHistory]
(
[VideoChangeId] [bigint] NOT NULL IDENTITY(1, 1),
[IncidentId] [bigint] NOT NULL,
[OldCreationCodeId] [smallint] NULL,
[NewCreationCodeId] [smallint] NULL,
[UserId] [uniqueidentifier] NOT NULL,
[ChangeDateTime] [datetime] NOT NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VideoChangeHistory_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
