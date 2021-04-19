SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetCommandForIVH]( @ivhid UNIQUEIDENTIFIER )
AS
	SELECT TOP 10
		REPLACE(RTRIM(CAST(Command AS VARCHAR(1024))), CHAR(63), '\0') AS Command,
		LastOperation,
		CommandId,
		ExpiryDate,
		AcknowledgedDate
	FROM dbo.Command
	WHERE IVHId = @ivhid
	AND Archived = 0
	ORDER BY LastOperation DESC


GO
