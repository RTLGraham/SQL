CREATE TABLE [dbo].[LW_LoneWorkerResponseType]
(
[ResponseTypeId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL,
[LastOperation] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LW_LoneWorkerResponseType] ADD CONSTRAINT [PK_LW_LoneWorkerResponseType] PRIMARY KEY CLUSTERED  ([ResponseTypeId]) ON [PRIMARY]
GO
