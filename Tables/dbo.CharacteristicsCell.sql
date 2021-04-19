CREATE TABLE [dbo].[CharacteristicsCell]
(
[CharCellId] [int] NOT NULL IDENTITY(1, 1),
[CharId] [int] NULL,
[RowIndex] [int] NULL,
[ColIndex] [int] NULL,
[TimeVal] [int] NULL,
[Distance] [float] NULL,
[Fuel] [float] NULL,
[ProcessInd] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CharacteristicsCell] ADD CONSTRAINT [PK_CharacteristicsCell] PRIMARY KEY CLUSTERED  ([CharCellId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CharacteristicsCell_CharId] ON [dbo].[CharacteristicsCell] ([CharId]) INCLUDE ([RowIndex], [ColIndex], [TimeVal], [Distance], [Fuel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CharacteristicsCell_ProcessInd] ON [dbo].[CharacteristicsCell] ([ProcessInd]) ON [PRIMARY]
GO
