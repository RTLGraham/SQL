CREATE TABLE [dbo].[STOPI]
(
[STOPIId] [bigint] NOT NULL,
[Text] [char] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL,
[Archived] [bit] NOT NULL,
[CustomerIntId] [int] NOT NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STOPI] ADD CONSTRAINT [PK_STOPI] PRIMARY KEY CLUSTERED  ([STOPIId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
