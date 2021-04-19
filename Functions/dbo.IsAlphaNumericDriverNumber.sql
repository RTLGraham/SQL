SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[IsAlphaNumericDriverNumber]
(
    @input VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
--    DECLARE @input VARCHAR(MAX)
    
--    SET @input = '100000035757A4'
----	SET @input = '100000059789r1'
--	SET @input = '100000059789æ1'
----	SET @input = '100000059789R2'
    
    -- allows spaces too
    DECLARE @result BIT,
			@count INT
    
    SELECT @count = LEN(dbo.GetNonAlphaCharacters(@input, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-.0123456789', ' '))
    
    IF @count > 0
		SET @result = 1
	ELSE
		SET @result = 0
    
    RETURN @result -- return result
END

GO
