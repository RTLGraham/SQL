CREATE TABLE [dbo].[LW_LoneWorkerAck]
(
[LoneWorkerAckId] [bigint] NOT NULL IDENTITY(1, 1),
[LoneWorkerId] [bigint] NOT NULL,
[ResponseTypeId] [int] NULL,
[UserId] [uniqueidentifier] NULL,
[ResponseDateTime] [datetime] NULL,
[Comment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LW_LoneWorkerAck] ADD CONSTRAINT [PK_LW_LoneWorkerAck] PRIMARY KEY CLUSTERED  ([LoneWorkerAckId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LW_LoneWorkerAck_LoneWorkerId] ON [dbo].[LW_LoneWorkerAck] ([LoneWorkerId]) ON [PRIMARY]
GO
