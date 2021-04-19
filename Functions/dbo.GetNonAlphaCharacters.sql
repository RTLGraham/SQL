SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetNonAlphaCharacters] (@Data VARCHAR(MAX), @DataToReplace VARCHAR(100), @ReplacedWithData VARCHAR(100))
RETURNS VARCHAR(MAX)
 
BEGIN
     
    DECLARE @TranslaedData VARCHAR(MAX)
     
    ;WITH CTE(PosToReplace,Data,DataToReplace,ReplacedWithData) AS
    (
    SELECT 1,CAST(@Data AS VARCHAR(MAX)) AS Data,CAST(SUBSTRING(@DataToReplace,1,1) AS VARCHAR(MAX)) AS DataToReplace,CAST(SUBSTRING(@ReplacedWithData,1,1) AS VARCHAR(MAX)) AS ReplacedWithData
    UNION ALL
    SELECT C.PosToReplace+1 AS PosToReplace , CAST(REPLACE(C.Data,C.DataToReplace,C.ReplacedWithData) AS VARCHAR(MAX)) AS Data,CAST(SUBSTRING(@DataToReplace,PosToReplace+1,1) AS VARCHAR(MAX)) AS DataToReplace,CAST(SUBSTRING(@ReplacedWithData,PosToReplace+1,1) AS VARCHAR(MAX)) AS ReplacedWithData
    FROM CTE C
    WHERE C.PosToReplace <= LEN(@DataToReplace)
    )
    SELECT  @TranslaedData = C.Data FROM CTE C WHERE C.PosToReplace = LEN(@DataToReplace)+1
         
    RETURN @TranslaedData                          
     
END
GO
