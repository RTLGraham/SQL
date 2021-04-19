CREATE TABLE [dbo].[SCAM_VideoIn]
(
[SCAM_VideoInId] [int] NOT NULL IDENTITY(1, 1),
[Video] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Acc] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stime] [datetime] NULL,
[Etime] [datetime] NULL,
[VideoStatus] [int] NULL,
[ProjectId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessInd] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SCAM_VideoIn] ADD CONSTRAINT [PK_SCAM_VideoIn] PRIMARY KEY CLUSTERED  ([SCAM_VideoInId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
