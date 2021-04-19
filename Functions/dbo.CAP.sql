SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[CAP]
    (
      @Value FLOAT,
      @maxValue FLOAT
    )
RETURNS FLOAT
AS BEGIN
    DECLARE @Result FLOAT
    IF @Value > @maxValue 
        SELECT  @Result = @Maxvalue
    ELSE 
        SELECT  @Result = @Value
    RETURN @Result
   END ;

GO
