CREATE TABLE [dbo].[LEO_ApplicationComponent]
(
[ApplicationComponentId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationId] [int] NOT NULL,
[ComponentId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationComponent] ADD CONSTRAINT [PK_LEO_ApplicationComponent] PRIMARY KEY CLUSTERED  ([ApplicationComponentId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationComponent] ADD CONSTRAINT [FK_LEO_ApplicationComponent_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[LEO_Application] ([ApplicationId])
GO
ALTER TABLE [dbo].[LEO_ApplicationComponent] ADD CONSTRAINT [FK_LEO_ApplicationComponent_Component] FOREIGN KEY ([ComponentId]) REFERENCES [dbo].[LEO_Component] ([ComponentId])
GO
