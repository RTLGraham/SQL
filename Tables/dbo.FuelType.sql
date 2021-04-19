CREATE TABLE [dbo].[FuelType]
(
[FuelTypeId] [tinyint] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CO2ScaleFactor] [float] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_FuelType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_FuelType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelType] ADD CONSTRAINT [PK_FuelType] PRIMARY KEY CLUSTERED  ([FuelTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
