CREATE TABLE [dbo].[KronosAbsense]
(
[KronosAbsenseId] [int] NOT NULL IDENTITY(1, 1),
[KronosAbsenseTypeId] [int] NOT NULL,
[DriverId] [uniqueidentifier] NOT NULL,
[UserId] [uniqueidentifier] NOT NULL,
[Comment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_KronosAbsense_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_KronosAbsense_Archived] DEFAULT ((0)),
[Date] [datetime] NULL,
[Duration] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosAbsense] ADD CONSTRAINT [PK_KronosAbsense] PRIMARY KEY CLUSTERED  ([KronosAbsenseId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosAbsense] ADD CONSTRAINT [FK_KronosAbsense_KronosAbsenseType] FOREIGN KEY ([KronosAbsenseTypeId]) REFERENCES [dbo].[KronosAbsenseType] ([KronosAbsenseTypeId])
GO
