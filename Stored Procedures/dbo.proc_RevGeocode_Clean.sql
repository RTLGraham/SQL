SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_RevGeocode_Clean] 
AS

-- This procedure deletes RevGeocode entries with a Low confidence level that are more than 2 months old 
DELETE
FROM dbo.RevGeocode
WHERE Confidence = 'L'
  AND DATEDIFF(mm, InsertDateTime, GETUTCDATE()) > 1
  

GO
