CREATE TABLE [dbo].[LEO_Component]
(
[ComponentId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Compo__Archi__66ABE4D6] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__LEO_Compo__LastO__67A0090F] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Component] ADD CONSTRAINT [PK_LEO_Component] PRIMARY KEY CLUSTERED  ([ComponentId]) ON [PRIMARY]
GO
