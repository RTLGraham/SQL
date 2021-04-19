SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_CFG_History_SavePendingConfig_20190529]
(
	@vid UNIQUEIDENTIFIER,
	@keyid INT,
	@keyvalue VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN

          DECLARE   @IVHId int;
	
	SELECT    @IVHId = I.IVHIntId
	FROM      dbo.Vehicle V
	          INNER JOIN dbo.IVH I ON I.IVHId = V.IVHId
	WHERE     V.VehicleId = @vid;

          --Remove old pending value first
          DELETE    CFG_History
          WHERE     KeyID = @keyid
		  AND		IVHIntId = @IVHId
          AND       EndDate IS NULL
          AND       Status IS NULL;
	
	IF NOT EXISTS (SELECT 1
	          FROM      CFG_History
	          WHERE     IVHIntID = @IVHId
	          AND       KeyID = @keyid
	          AND       KeyValue = @keyvalue
	          AND       EndDate IS NULL
	          AND       Status = 1)
	BEGIN
	          DECLARE   @date datetime;
	          SET       @date = GETUTCDATE();
	
                    INSERT    CFG_History(IVHIntID, KeyID, KeyValue, StartDate, EndDate, Status, LastOperation)
                    VALUES    (@IVHId, @keyid, @keyvalue, @date, NULL, NULL, @date);
                    
                    DECLARE   @newvalueid int;
                    SET       @newvalueid = SCOPE_IDENTITY();
                    
                    --If the index from the key is < 0, it does not form part of the command, so is automatically activated
                    IF EXISTS (SELECT 1 FROM CFG_KeyCommand WHERE KeyId = @keyid AND IndexPos >= 0) RETURN;
                    
	          UPDATE    CFG_History
	          SET       EndDate = @date
	          WHERE     IVHIntID = @IVHId
	          AND       KeyID = @keyid
	          AND       EndDate IS NULL
	          AND       Status = 1;
	          
	          UPDATE    CFG_History
	          SET       StartDate = @date,
	                    Status = 1
	          WHERE     HistoryId = @newvalueid;
          END;
END;
GO
