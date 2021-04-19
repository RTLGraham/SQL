CREATE TABLE [dbo].[TZ_DstOffsets]
(
[TimeZoneId] [smallint] NOT NULL,
[StartDateTime] [datetime] NOT NULL,
[EndDateTime] [datetime] NOT NULL,
[DstOffset] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TZ_DstOffsets_IdStartEnd] ON [dbo].[TZ_DstOffsets] ([TimeZoneId], [StartDateTime], [EndDateTime]) INCLUDE ([DstOffset]) ON [PRIMARY]
GO
