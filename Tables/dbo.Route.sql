CREATE TABLE [dbo].[Route]
(
[RouteID] [int] NOT NULL IDENTITY(1, 1),
[RouteNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RouteName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Route_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_Route_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Route] ADD CONSTRAINT [PK_Route] PRIMARY KEY CLUSTERED  ([RouteID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
