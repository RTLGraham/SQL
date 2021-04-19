SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[GetContractNameFromGroupName] 
(
	@groupName VARCHAR(MAX)
)
RETURNS varchar(MAX) 
AS  
BEGIN 
	--DECLARE @groupName VARCHAR(MAX)
	
	--SET @groupName = 'Esso: Stanlow'
	--SET @groupName = 'Lewis Tankers AirBP'
	--SET @groupName = 'Shell Denmark: Alborg'
	--SET @groupName = 'Lewis Tankers AirBP'
	
	DECLARE @result VARCHAR(MAX),
			@index INT
	
	SET @index = CHARINDEX(':', @groupName, 0)
	
	IF @index > 0 AND @index < LEN(@groupName)
	BEGIN
		SET @result = SUBSTRING(@groupName, 0, @index)
	END
	ELSE
	BEGIN
		SET @result = @groupName
	END
	
	--SELECT @result
	
	RETURN @result
END



GO
