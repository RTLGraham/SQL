CREATE TABLE [dbo].[MileageClaimCustomer]
(
[MileageClaimCustomerId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MileageClaimCustomer_MileageClaimCustomerId] DEFAULT (newid()),
[CustomerId] [uniqueidentifier] NOT NULL,
[PrivatePencePerMile] [int] NULL,
[BusinessPencePerMile] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MileageClaimCustomer] ADD CONSTRAINT [PK_MileageClaimCustomer] PRIMARY KEY CLUSTERED  ([MileageClaimCustomerId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MileageClaimCustomer] ADD CONSTRAINT [FK_MileageClaimCustomer_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
