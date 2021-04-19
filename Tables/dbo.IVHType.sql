CREATE TABLE [dbo].[IVHType]
(
[IVHTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Manufacturer] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Model] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WriteCommandPrefix] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WriteCommandSuffix] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReadCommandPrefix] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReadCommandSuffix] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDataNamePrefix] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDataNameSuffix] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_IVHType_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_IVHType_LastOperation] DEFAULT (getdate()),
[DriverIdType] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVHType] ADD CONSTRAINT [PK_IVHTypeId] PRIMARY KEY CLUSTERED  ([IVHTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVHType] ADD CONSTRAINT [UC_IVHType_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
