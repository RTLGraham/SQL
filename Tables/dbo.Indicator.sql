CREATE TABLE [dbo].[Indicator]
(
[IndicatorId] [int] NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Indicator_Name] DEFAULT ('default'),
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_Indicator_Archived] DEFAULT ((0)),
[HighLow] [bit] NULL,
[Parameter] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_Indicator_LastModified] DEFAULT (getdate()),
[IndicatorClass] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rounding] [smallint] NULL,
[DisplaySeq] [smallint] NULL,
[UnitOfMeasureType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Indicator] ADD CONSTRAINT [PK_Indicator] PRIMARY KEY CLUSTERED  ([IndicatorId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Indicator_Name] ON [dbo].[Indicator] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
