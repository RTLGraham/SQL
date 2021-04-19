SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetScheduledParameter] 
(
	@parametertypeid INT,
	@name VARCHAR(255),
	@value NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

--	DECLARE @parametertypeid INT,
--			@name VARCHAR(255),
--			@value NVARCHAR(MAX)
--
--	SET @parametertypeid = 10
--	SET @name = 'idle'
--	SET @value = '5'--'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

	DECLARE @result NVARCHAR(MAX)

	SELECT @result = '@' + @name + '=' +
	CASE @parametertypeid
		WHEN 10 THEN ''
		WHEN 11 THEN ''
		WHEN 13 THEN ''
		WHEN 14 THEN ''
		ELSE CASE WHEN @value IS NULL THEN '' ELSE '''' END
	END	+ ISNULL(@value, 'NULL') +
	CASE @parametertypeid
		WHEN 10 THEN ''
		WHEN 11 THEN ''
		WHEN 13 THEN ''
		WHEN 14 THEN ''
		ELSE CASE WHEN @value IS NULL THEN '' ELSE '''' END
	END	

--	SELECT @Result	
	RETURN @result
END



GO
