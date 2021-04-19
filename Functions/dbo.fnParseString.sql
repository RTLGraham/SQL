SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 --Found this on t'internet.
 --Basically takes a delimited string, and returns you the n'th item from it.
 --changed so that section must be positive and returns null if return string is non numeric 
CREATE FUNCTION [dbo].[fnParseString]
(
	@Section SMALLINT,
	@Delimiter CHAR,
	@Text NVARCHAR(MAX)
)
RETURNS VARCHAR(8000)
AS

BEGIN

	DECLARE	@NextPos SMALLINT,
		@LastPos SMALLINT,
		@Found SMALLINT

	SELECT	@NextPos = CHARINDEX(@Delimiter, @Text, 1),
		@LastPos = 0,
		@Found = 1

	WHILE @NextPos > 0 AND ABS(@Section) <> @Found
		SELECT	@LastPos = @NextPos,
			@NextPos = CHARINDEX(@Delimiter, @Text, @NextPos + 1),
			@Found = @Found + 1

	RETURN	CASE WHEN @Found <> ABS(@Section) OR @Section = 0 OR ISNUMERIC(SUBSTRING(@Text, @LastPos + 1, CASE WHEN @NextPos = 0 THEN DATALENGTH(@Text) - @LastPos ELSE @NextPos - @LastPos - 1 END)) = 0 
				 THEN NULL
				 ELSE SUBSTRING(@Text, @LastPos + 1, CASE WHEN @NextPos = 0 THEN DATALENGTH(@Text) - @LastPos ELSE @NextPos - @LastPos - 1 END)
			END
END

GO
