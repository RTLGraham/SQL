CREATE TABLE [dbo].[SpeedwiseCustomer]
(
[CustomerDefinitionID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CustomerDefinition_CustomerDefinitionID] DEFAULT (newid()),
[CustomerId] [uniqueidentifier] NOT NULL,
[Treshhold] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SpeedwiseCustomer] ADD CONSTRAINT [PK_CustomerDefinition] PRIMARY KEY CLUSTERED  ([CustomerDefinitionID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SpeedwiseCustomer] ADD CONSTRAINT [FK_SpeedwiseCustomer_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
