CREATE TABLE [dbo].[VehicleCommand]
(
[IVHId] [uniqueidentifier] NOT NULL,
[Command] [binary] (1024) NULL,
[ExpiryDate] [smalldatetime] NULL,
[AcknowledgedDate] [smalldatetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleCommand_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleCommand_Archived] DEFAULT ((0)),
[CommandId] [int] NOT NULL IDENTITY(1, 1),
[ProcessInd] [bit] NULL,
[ReceivedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleCommand] ADD CONSTRAINT [PK_Command] PRIMARY KEY CLUSTERED  ([CommandId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleCommand_AckDate_Arch_ExpDate] ON [dbo].[VehicleCommand] ([AcknowledgedDate], [Archived], [ExpiryDate]) INCLUDE ([IVHId], [Command], [CommandId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleCommand_IVH] ON [dbo].[VehicleCommand] ([IVHId], [ExpiryDate], [AcknowledgedDate], [ReceivedDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleCommand_Proc_Dates] ON [dbo].[VehicleCommand] ([ProcessInd], [AcknowledgedDate], [ExpiryDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleCommand] ADD CONSTRAINT [FK_VehicleCommand_IVH] FOREIGN KEY ([IVHId]) REFERENCES [dbo].[IVH] ([IVHId])
GO
