SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[udf_TitleCase] (@InputString NVARCHAR(4000) )
RETURNS NVARCHAR(4000)
AS
 BEGIN
 DECLARE @Index INT
 DECLARE @Char NCHAR(1)
DECLARE @OutputString NVARCHAR(255)
SET @OutputString = LOWER(@InputString)
SET @Index = 2
SET @OutputString =
STUFF(@OutputString, 1, 1,UPPER(SUBSTRING(@InputString,1,1)))
WHILE @Index <= LEN(@InputString)
BEGIN
 SET @Char = SUBSTRING(@InputString, @Index, 1)
IF @Char IN (' ', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ';', ':', '!', ',', '.', '_', '-', '/', '&','''','(')
IF @Index + 1 <= LEN(@InputString)
BEGIN
 IF @Char != ''''
OR
UPPER(SUBSTRING(@InputString, @Index + 1, 1)) != 'S'
SET @OutputString =
STUFF(@OutputString, @Index + 1, 1,UPPER(SUBSTRING(@InputString, @Index + 1, 1)))
END
 SET @Index = @Index + 1
END
 RETURN ISNULL(@OutputString,'')
END 
GO
