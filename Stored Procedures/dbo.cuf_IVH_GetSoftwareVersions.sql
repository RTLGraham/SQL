SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_IVH_GetSoftwareVersions]
    (
		@cid UNIQUEIDENTIFIER,
		@unitType INT
    )
AS 
    BEGIN
        SELECT
                  SoftwareId ,
                  Name ,
                  [Description] ,
                  UnitType ,
                  [FileName] ,
                  FileSize ,
                  FileCheckSum ,
                  TFTPIPAddress ,
                  LastOperation ,
                  Archived
        FROM dbo.IVHSoftware
        WHERE Archived = 0
    END




GO
