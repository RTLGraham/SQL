CREATE TABLE [dbo].[HardwareSupplier]
(
[HardwareSupplierId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_HardwareSupplier_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HardwareSupplier] ADD CONSTRAINT [PK_HardwareSupplier] PRIMARY KEY CLUSTERED  ([HardwareSupplierId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_HardwareSupplierName] ON [dbo].[HardwareSupplier] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
