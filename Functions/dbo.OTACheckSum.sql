SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[OTACheckSum] 
(
	@otastring VARCHAR(1024)
)
RETURNS CHAR(2)
AS
BEGIN

--	DECLARE @otastring VARCHAR(1024)
--	SET @otastring = '>STCH100451168572D316D91.103.176.244"NST_SWC_NON_SS1_MB5_1_4_99";PW=00000000;ID=B2802314;*'

	DECLARE @result CHAR(2),
			@i INT,
			@byte INT,
			@int INT,
			@char1 CHAR(1),
			@char2 CHAR(1)
			
	SET @i = 1
	SET @byte = 0
	
	WHILE @i <= LEN(@otastring)
	BEGIN
		SET @byte = @byte ^ ASCII(SUBSTRING(@otastring, @i, 1))
		SET @i = @i + 1
	END
	
	SELECT @int = @byte / 16
	SELECT @char1 = CASE @int
		WHEN 0 THEN '0'
		WHEN 1 THEN '1'
		WHEN 2 THEN '2'
		WHEN 3 THEN '3'
		WHEN 4 THEN '4'
		WHEN 5 THEN '5'
		WHEN 6 THEN '6'
		WHEN 7 THEN '7'
		WHEN 8 THEN '8'
		WHEN 9 THEN '9'
		WHEN 10 THEN  'A' 
		WHEN 11 THEN  'B' 
		WHEN 12 THEN  'C' 
		WHEN 13 THEN  'D'
		WHEN 14 THEN  'E'
		WHEN 15 THEN  'F'
	END	
	
	SELECT @int = @byte % 16
	SELECT @char2 = CASE @int
		WHEN 0 THEN '0'
		WHEN 1 THEN '1'
		WHEN 2 THEN '2'
		WHEN 3 THEN '3'
		WHEN 4 THEN '4'
		WHEN 5 THEN '5'
		WHEN 6 THEN '6'
		WHEN 7 THEN '7'
		WHEN 8 THEN '8'
		WHEN 9 THEN '9'
		WHEN 10 THEN  'A' 
		WHEN 11 THEN  'B' 
		WHEN 12 THEN  'C' 
		WHEN 13 THEN  'D'
		WHEN 14 THEN  'E'
		WHEN 15 THEN  'F'
	END	
	
	SELECT @result = @char1 + @char2	
	  
	RETURN @result
END
GO
