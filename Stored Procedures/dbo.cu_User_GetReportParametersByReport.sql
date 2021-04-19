SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_User_GetReportParametersByReport]
    (
      @ReportId UNIQUEIDENTIFIER
    )
AS 

-- This sp retrieves the parameters necessary for report execution and also dynamically builds a pseudo parameter
-- containing the list of RDLs available for the report

DECLARE @newline CHAR(2),
		@labelstring NVARCHAR(MAX),
		@valuestring NVARCHAR(MAX),
		@default NVARCHAR(5)
SET @newline = CHAR(13) + CHAR(10)

DECLARE @RDLList TABLE (ReportRDLId INT, DisplaySeq SMALLINT, Descrip VARCHAR(MAX))

-- Determine RDL List
INSERT INTO @RDLList (ReportRDLId, DisplaySeq, Descrip)
SELECT ReportRDLId, DisplaySeq, Description
FROM dbo.ReportRDL
WHERE ReportId = @ReportId
  AND Archived = 0

-- Build labelstring string
SET @labelstring = NULL
IF (SELECT COUNT(*) FROM @RDLList) > 0
BEGIN
	SELECT @labelstring = COALESCE(@labelstring + '|', '') + Descrip
	FROM @RDLList
	ORDER BY DisplaySeq	
END

-- Build valuestring string
SET @valuestring = NULL
IF (SELECT COUNT(*) FROM @RDLList) > 0
BEGIN
	SELECT @valuestring = COALESCE(@valuestring + '|', '') + CONVERT(NVARCHAR(5), ReportRDLId)
	FROM @RDLList
	ORDER BY DisplaySeq	
END

SELECT @default = ReportRDLId
FROM dbo.ReportRDL
WHERE ReportId = @ReportId
  AND Archived = 0
  AND DisplaySeq = 0

SELECT	rp.ReportParameterId,
		rp.Seq,
		rp.Name,
		rp.ReportParameterTypeId,
		rp.IsList,
		rp.Labels,
		rp.[Values],
		rp.Prompt,
		rp.Nullable,
		rp.[Default]
FROM dbo.ReportParameter rp
WHERE rp.ReportId = @ReportId
  AND rp.Archived = 0

UNION

SELECT	0 AS ReportParameterId,
		99 AS Seq,
		'rdl' AS [Name],
		19 AS ReportParameterTypeId,
		1 AS IsList,
		@labelstring AS Labels,
		@valuestring AS [Values],
		1 AS Prompt,
		0 AS Nullable,
		@default AS [Default]






GO
