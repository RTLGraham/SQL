CREATE TABLE [dbo].[WorkingHours]
(
[CustomerID] [uniqueidentifier] NOT NULL,
[MonStart] [datetime] NULL,
[MonEnd] [datetime] NULL,
[TueStart] [datetime] NULL,
[TueEnd] [datetime] NULL,
[WedStart] [datetime] NULL,
[WedEnd] [datetime] NULL,
[ThuStart] [datetime] NULL,
[ThuEnd] [datetime] NULL,
[FriStart] [datetime] NULL,
[FriEnd] [datetime] NULL,
[SatStart] [datetime] NULL,
[SatEnd] [datetime] NULL,
[SunStart] [datetime] NULL,
[SunEnd] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkingHours] ADD CONSTRAINT [PK_WorkingHours] PRIMARY KEY CLUSTERED  ([CustomerID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
