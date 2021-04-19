SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 18/08/2016
-- Description:	Determines if a CAM Dispatcher Process is running
--				Clears running state and reports if overdue
-- ====================================================================
CREATE PROCEDURE [dbo].[IsCAMDispatcherRunning] 
(
	@dispatcher VARCHAR(100),
	@running BIT OUTPUT	
)
AS
BEGIN
	DECLARE @timestamp DATETIME
	
	SELECT @timestamp = StartTime
	FROM dbo.CAM_SP_DispatcherRunning
	WHERE Dispatcher = @dispatcher

	IF DATEDIFF(ss, ISNULL(@timestamp, GETDATE()), GETDATE()) > 600
	BEGIN
		-- Process has been running for 10 minutes so clear flag and report occurrence
		DELETE	
		FROM dbo.CAM_SP_DispatcherRunning
		WHERE Dispatcher = @dispatcher

		-- Insert entry for NKVD to alert occurrence
		INSERT INTO dbo.NKVDAlerts (NKVDSubject, NKVDBody, EventDateTime)
		VALUES  ('CAM SP Processing for dispatcher ' + @dispatcher, 'Database thinks process has been running for more than 10 minutes so has cleared process flag to allow process to start.', GETDATE())

		SET @timestamp = NULL
	END	

	SELECT @running = CASE WHEN @timestamp IS NULL THEN 0 ELSE 1 END	
END




GO
