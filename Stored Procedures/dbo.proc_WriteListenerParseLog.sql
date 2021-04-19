SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteListenerParseLog] 
	@port INT, @lname VARCHAR(32), @datetime DATETIME, @raw INT, @parsing INT, @parseindex INT, @prevduration INT,
	@prevdurationAvg FLOAT = NULL, @prevdurationAvgEvents FLOAT = NULL, @prevdurationAvgAccums FLOAT = NULL, @prevdurationAvgOther FLOAT = NULL
AS	
	INSERT INTO dbo.ListenerParseLog (ListenerPort, ListenerName, LogDateTime, RawCount, CurrentParseSize, CurrentParseIndex, PrevParseDurationSecs, 
			AvgPrevParseDurationMs, AvgPrevParseDurationEventsMs, AvgPrevParseDurationAccumsMs, AvgPrevParseDurationOtherMs)
	VALUES (@port, @lname, @datetime, @raw, @parsing, @parseindex, @prevduration, 
			@prevdurationAvg, @prevdurationAvgEvents, @prevdurationAvgAccums, @prevdurationAvgOther)

GO
