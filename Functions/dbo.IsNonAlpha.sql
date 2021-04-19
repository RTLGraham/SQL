SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- User Defined Function

CREATE FUNCTION [dbo].[IsNonAlpha]
(
    @input VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
    -- allows spaces too
    DECLARE @result BIT 
    SET @result = 1 -- default result to true
    IF (PATINDEX('%[^a-Z,'' '']%', @input) = 0)
    BEGIN
        SET @result = 0 -- found a non-alphanumeric character
    END
    RETURN @result -- return result
END


GO
