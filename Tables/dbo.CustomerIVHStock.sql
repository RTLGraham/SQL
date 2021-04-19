CREATE TABLE [dbo].[CustomerIVHStock]
(
[IVHId] [uniqueidentifier] NOT NULL,
[CustomerId] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CustomerIVHStock_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CustomerIVHStock_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerIVHStock] ADD CONSTRAINT [FK_CustomerIVHStock_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[CustomerIVHStock] ADD CONSTRAINT [FK_CustomerIVHStock_IVH] FOREIGN KEY ([IVHId]) REFERENCES [dbo].[IVH] ([IVHId])
GO
