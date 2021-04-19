CREATE TABLE [dbo].[CustomerDriver]
(
[DriverId] [uniqueidentifier] NOT NULL,
[CustomerId] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CustomerDriver_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CustomerDriver_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerDriver_CustomerId] ON [dbo].[CustomerDriver] ([CustomerId], [StartDate], [EndDate]) INCLUDE ([Archived], [DriverId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerDriver_DriverId] ON [dbo].[CustomerDriver] ([DriverId], [StartDate], [EndDate]) INCLUDE ([Archived], [CustomerId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerDriver] ADD CONSTRAINT [FK_CustomerDriver_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[CustomerDriver] ADD CONSTRAINT [FK_CustomerDriver_Driver] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
