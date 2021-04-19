CREATE TABLE [dbo].[CustomerCameraStock]
(
[CustomerCameraStockId] [uniqueidentifier] NOT NULL,
[CameraId] [uniqueidentifier] NOT NULL,
[CustomerId] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CustomerCameraStock_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CustomerCameraStock_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerCameraStock] ADD CONSTRAINT [PK_CustomerCameraStock] PRIMARY KEY CLUSTERED  ([CustomerCameraStockId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerCameraStock] ADD CONSTRAINT [FK_CustomerCameraStock_Camera] FOREIGN KEY ([CameraId]) REFERENCES [dbo].[Camera] ([CameraId])
GO
ALTER TABLE [dbo].[CustomerCameraStock] ADD CONSTRAINT [FK_CustomerCameraStock_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
