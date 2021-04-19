SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cu_ReportConfiguration_GetByCustomerId]
(
	@cid UNIQUEIDENTIFIER=NULL,
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

--DECLARE @cid UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER

--SET @cid = N'21451A9F-AB08-4D28-BD0C-F64FF409075A'
----SET @cid = NULL
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'

SELECT  rc.ReportConfigurationId, 
		rc.CustomerId, 
        c.Name AS CustomerName, 
		rc.Name, 
		rc.Description, 
		rc.RDL,
		CASE WHEN SUM(ic.Weight) > 100 THEN 'C' ELSE MAX(i.IndicatorClass) END AS ReportType
FROM dbo.ReportConfiguration rc
	INNER JOIN dbo.IndicatorConfig ic ON rc.ReportConfigurationId = ic.ReportConfigurationId
	INNER JOIN dbo.Indicator i ON ic.IndicatorId = i.IndicatorId
	LEFT OUTER JOIN dbo.Customer c ON rc.CustomerId = c.CustomerId
WHERE (rc.CustomerId IS NULL OR rc.CustomerId = @cid OR @cid IS NULL)
	AND ic.Archived = 0 AND i.Archived = 0 AND i.IndicatorClass IS NOT NULL
GROUP BY rc.ReportConfigurationId, 
		rc.CustomerId, 
        c.Name, 
		rc.Name, 
		rc.Description, 
		rc.RDL	
HAVING SUM(ic.Weight) >= 100
ORDER BY rc.Name

END
GO
