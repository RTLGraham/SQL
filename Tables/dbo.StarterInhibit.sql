CREATE TABLE [dbo].[StarterInhibit]
(
[StarterInhibitId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[Status] [int] NOT NULL,
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_StarterInhibit_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_StarterInhibit_Archived] DEFAULT ((0)),
[UserId] [uniqueidentifier] NULL,
[CommandId] [int] NULL,
[EventId] [bigint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StarterInhibit] ADD CONSTRAINT [PK_StarterInhibit] PRIMARY KEY CLUSTERED  ([StarterInhibitId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
