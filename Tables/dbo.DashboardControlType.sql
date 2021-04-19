CREATE TABLE [dbo].[DashboardControlType]
(
[DashboardControlTypeID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__Dashboard__Archi__33607FA3] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DashboardControlType] ADD CONSTRAINT [PK__DashboardControl__326C5B6A] PRIMARY KEY CLUSTERED  ([DashboardControlTypeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
