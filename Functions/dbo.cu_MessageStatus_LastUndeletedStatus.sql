SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[cu_MessageStatus_LastUndeletedStatus]
(
	@messageId INT
) RETURNS INT AS
BEGIN
--DECLARE @messageId INT
--SET @messageId = 120;

	DECLARE @msgStatusId INT;
	
	WITH MessageStatusHistoryCTE (MessageId, MessageStatusId, LastModified) AS
	(
	   SELECT TOP 2
		  MessageId,
		  MessageStatusId,
		  LastModified
	   FROM dbo.MessageStatusHistory
	   WHERE MessageId = @messageId
	)

	SELECT @msgStatusId = MessageStatusId
	FROM MessageStatusHistoryCTE
	WHERE MessageStatusId != 104
	
	RETURN @msgStatusId
END

GO
