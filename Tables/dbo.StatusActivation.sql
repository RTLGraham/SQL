CREATE TABLE [dbo].[StatusActivation]
(
[StatusActivationId] [tinyint] NOT NULL IDENTITY(1, 1),
[Code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StatusActivation] ADD CONSTRAINT [PK_StatusActivation] PRIMARY KEY CLUSTERED  ([StatusActivationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_StatusActivation] ON [dbo].[StatusActivation] ([Code]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
