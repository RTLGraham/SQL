CREATE TABLE [dbo].[IndicatorConfig]
(
[IndicatorConfigId] [int] NOT NULL IDENTITY(1, 1),
[IndicatorId] [int] NOT NULL,
[ReportConfigurationId] [uniqueidentifier] NULL,
[Min] [float] NULL,
[Max] [float] NULL,
[Weight] [float] NULL,
[GYRGreenMax] [float] NULL,
[GYRAmberMax] [float] NULL,
[Target] [float] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_IndicatorConfig_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_IndicatorConfig_LastModified] DEFAULT (getdate()),
[GYRRedMax] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IndicatorConfig] ADD CONSTRAINT [PK_IndicatorConfig] PRIMARY KEY CLUSTERED  ([IndicatorConfigId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IndicatorConfig_IndicatorIdConfig] ON [dbo].[IndicatorConfig] ([IndicatorId], [ReportConfigurationId], [Archived]) INCLUDE ([Min], [Max], [Weight]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IndicatorConfig] ADD CONSTRAINT [FK_IndicatorConfig_Indicator] FOREIGN KEY ([IndicatorId]) REFERENCES [dbo].[Indicator] ([IndicatorId])
GO
