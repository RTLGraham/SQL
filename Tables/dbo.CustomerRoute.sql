CREATE TABLE [dbo].[CustomerRoute]
(
[CustomerRouteID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [uniqueidentifier] NOT NULL,
[RouteID] [int] NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CustomerRoute_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CustomerRoute_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerRoute] ADD CONSTRAINT [PK_CustomerRoute] PRIMARY KEY CLUSTERED  ([CustomerRouteID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerRoute] ADD CONSTRAINT [FK_CustomerRoute_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[CustomerRoute] ADD CONSTRAINT [FK_CustomerRoute_Route] FOREIGN KEY ([RouteID]) REFERENCES [dbo].[Route] ([RouteID])
GO
