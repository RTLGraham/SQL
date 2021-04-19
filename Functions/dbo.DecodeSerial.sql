SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[DecodeSerial] 
(
	@serial varchar(MAX) 
)

RETURNS varchar(MAX)

AS

BEGIN

RETURN CONCAT( LEFT(RIGHT(CONCAT('0', CONVERT(VARCHAR(2), (ASCII(@serial)-56))),2),1),
 RIGHT(LEFT(@serial,2),1), RIGHT(convert(VARCHAR(2),
  (ASCII(@serial)-56)),1),RIGHT(@serial,6))

END

GO
