SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ParseCTCEString]
	(
		@eventdatastring VARCHAR(1024)
	) 
	 
	RETURNS @parsedata TABLE 
	(
		Network VARCHAR(3)
	)
	AS  
	BEGIN 
	
--		DECLARE @eventdatastring VARCHAR(1024)
--		SET @eventdatastring = '0,1,19200,255,1,2,9600,1,1,0'
--	
--		DECLARE @parsedata TABLE 
--		(
--			Network VARCHAR(3)
--		)
	
		DECLARE @Network VARCHAR(3),
				@apn VARCHAR(30),
				@user VARCHAR(30),
				@password VARCHAR(30)
				
		SELECT @apn = VALUE
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 1
		SELECT @user = VALUE
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 2
		SELECT @password = VALUE
		FROM dbo.Split(@eventdatastring, ',')
		WHERE Id = 3

		SET @Network = NULL
		IF @apn = 'internet' AND @user = 'web' AND @password = 'web' SET @Network = 'VFU'
		IF @apn = 'wigdsp.com' AND @user = 'rain' AND @password = 'rain' SET @Network = 'WLR'
		IF @apn = 'wlapn.com' AND @user = 'handsf' AND @password = 'handsf' SET @Network = 'WLH'
		IF @apn = 'gprs.swisscom.ch' AND @user IS NULL AND @password IS NULL SET @Network = 'SWC'
		IF @apn = 'mobile.o2.co.uk' AND @user = 'bypass' AND @password = 'password' SET @Network = 'O2U'
		IF @apn = 'stream.co.uk' AND @user = 'streamip' AND @password = 'streamip' SET @Network = 'STR'
		IF @apn = 'telstra.internet' AND @user IS NULL AND @password IS NULL SET @Network = 'TEL'
		IF @apn = 'www.internet.mtelia.dk' AND @user = 'telia' AND @password = '1010' SET @Network = 'TLD'
		IF @apn = 'online.telia.se' AND @user IS NULL AND @password IS NULL SET @Network = 'TLS'
		IF @apn = 'web.manxpronto.net' AND @user = 'gprs' AND @password = 'gprs' SET @Network = 'MNX'
		IF @apn = 'orangeinternet' AND @user IS NULL AND @password IS NULL SET @Network = 'ORA'
		IF @apn = 'Gammatelecom.com' AND @user IS NULL AND @password IS NULL SET @Network = 'FDG'
		IF @apn = 'mobile.o2.co.uk' AND @user = 'o2web' AND @password = 'password' SET @Network = 'FDO'
		IF @apn = 'vm2m' AND @user = 't' AND @password = 't' SET @Network = 'FDV'  
  
		-- Populate the result table
		INSERT INTO @parsedata (Network)
		VALUES  (@Network)

		RETURN
--		SELECT *
--		FROM @parsedata
		
	END

GO
