CREATE TABLE [dbo].[IVHSoftware]
(
[SoftwareId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_IVHSoftware_SoftwareId] DEFAULT (newsequentialid()),
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitType] [int] NULL,
[FileName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSize] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileCheckSum] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TFTPIPAddress] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_IVHSoftware_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_IVHSoftware_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVHSoftware] ADD CONSTRAINT [PK_IVHSoftware] PRIMARY KEY CLUSTERED  ([SoftwareId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVHSoftware] ADD CONSTRAINT [UQ__IVHSoftware__22A007F5] UNIQUE NONCLUSTERED  ([SoftwareId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
