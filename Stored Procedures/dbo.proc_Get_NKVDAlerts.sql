SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- ====================================================================
-- Author:		Graham Pattison
-- Create date: 18/08/2016
-- Description:	Pass information through to NKVD for alert notification
-- ====================================================================
CREATE PROCEDURE [dbo].[proc_Get_NKVDAlerts] 
AS
BEGIN
	SET NOCOUNT ON	

	-- Mark rows currently in table to be processed
	UPDATE dbo.NKVDAlerts
	SET ProcessInd = 1
	
	-- Select alerts to be notified
	SELECT NKVDSubject AS Subject, NKVDBody AS Body, EventDateTime
	FROM dbo.NKVDAlerts
	WHERE ProcessInd = 1

	-- Clear notified alerts
	DELETE
    FROM dbo.NKVDAlerts
	WHERE ProcessInd = 1
END
GO
