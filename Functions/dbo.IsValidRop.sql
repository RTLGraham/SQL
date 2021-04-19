SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsValidRop] 
(
	@eventData NVARCHAR(MAX)
)
RETURNS BIT 
AS
BEGIN
	IF @eventData IS NULL
		RETURN 1  

	DECLARE @val NVARCHAR(MAX)

	SELECT @val = Value 
	FROM dbo.Split(@eventData, ',')
	WHERE Id = 1 

	IF @val LIKE 'STAT%'
		RETURN 0

	
	RETURN 1

END






GO
