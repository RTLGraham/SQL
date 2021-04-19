CREATE TABLE [dbo].[MessageHistory]
(
[MessageId] [int] NOT NULL IDENTITY(1, 1),
[MessageText] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[ReverseGeocode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [datetime] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_Message_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_Message_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageHistory] ADD CONSTRAINT [PK_MessageHistory] PRIMARY KEY CLUSTERED  ([MessageId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
