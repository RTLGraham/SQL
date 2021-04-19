CREATE TABLE [dbo].[HardwareType]
(
[HardwareTypeId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HardwareSupplierId] [int] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_HardwareType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HardwareType] ADD CONSTRAINT [PK_HardwareType] PRIMARY KEY CLUSTERED  ([HardwareTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_HardwareTypeName] ON [dbo].[HardwareType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HardwareType] ADD CONSTRAINT [FK_HardwareType_HardwareSupplier] FOREIGN KEY ([HardwareSupplierId]) REFERENCES [dbo].[HardwareSupplier] ([HardwareSupplierId])
GO
