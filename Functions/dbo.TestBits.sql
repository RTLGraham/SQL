SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[TestBits] (@switches smallint,  @mask smallint)
RETURNS bit

/*
	Tests bits in a variable.  Select the bits
	with a mask.  Bits not selected in the mask
	can be anything.  They are not considered.

	Return:
		1 - All the bits selected were 1.
		0 - All the bits selected were 0.
	 NULL - The bits selected were a mixture
			of 1 and 0.
*/

AS
BEGIN

	DECLARE @Result bit
	DECLARE @work smallint

	-- zero all switches that the mask
	-- is not testing (mask bit = 0)
	SET @work = @switches & @mask

	SET @Result =
	  CASE
		WHEN (@work = 0)
		  -- all tested switches are 0,
		  -- or mask is 0
		  THEN 0
		WHEN (@work ^ @mask) = 0
		  -- work = mask (@work ^ @mask)
		  -- so all tested switches are 1
		  THEN 1
		ELSE
		  -- then tested switches must be mixed 0 and 1
		  NULL 
	  END

	RETURN @Result
END
GO
