SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_GetLocalTime] @uid uniqueidentifier = NULL
As

SELECT dbo.TZ_GetTime(GETUTCDATE(),default,@uid)

GO
