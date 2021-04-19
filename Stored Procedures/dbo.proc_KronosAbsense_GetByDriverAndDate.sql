SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_KronosAbsense_GetByDriverAndDate]
(
	@dids NVARCHAR(MAX),
	@gids NVARCHAR(MAX),
	@date DATETIME,
	@types NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@edate DATETIME = NULL
)
AS
	SET NOCOUNT ON;

	--DECLARE @dids NVARCHAR(MAX),
	--		@gids NVARCHAR(MAX),
	--		@date DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER
	----SET @dids = N'32730CC7-44B1-4B15-B194-618180298CB0,CFC9903E-9B86-42D0-A7EF-16BF18E4AF9D,3CE29ECF-9DF8-4B4B-BCDD-29616755B419,18ABA55D-CE2D-4C40-8B63-87EB04790B32,7C8357A1-D79D-49F6-8377-710827A268B1'
	--SET @dids = N'35b215b7-a306-4855-815a-c51a2b49c145,37211256-a2c5-4e81-a097-6f68d5795346,ea7f9702-f0e9-47b8-8f41-454ed2889959,78cbdae8-8634-416e-8046-c721f196a34f,1168576b-c3a3-41e1-b630-3d2b99bd0b18,983aeb57-6600-42c3-ba24-8d307f5ad57f,26c8a9b2-2eb9-49a1-8c8d-dfba04c697c3,0d572bac-d832-4d53-a192-7f7c56e1d37b,51d84e06-84fb-451c-8a02-f86f0219c39a,5e9679ac-1b6f-4700-97e8-53bb46b0bc01,56e27377-a4c4-4318-8f21-cb7f7ce1f5c7,bb3428a6-b8a5-4e7a-a081-99806369285f,1b5600d4-85ae-4a78-b071-2ee555eb3300,98e7ece2-6aa1-41d9-baa9-8b9cab5d5fd2,229a7988-0186-47f4-90f2-38cb92369f49,0071ede5-3222-4a5f-a00c-eb679c17b6fc,071410d1-1b88-40e7-8d81-ade51d9683e9,843eeab8-ec94-4923-8327-402b09f64f1f,a018c7cb-ee9a-4e3f-b294-db370320246e,a0842cd2-4540-4c18-96f9-5e0d2219d8cb,3ce29ecf-9df8-4b4b-bcdd-29616755b419,324c9111-443b-4eda-92da-5cc81e4978c6,62baf2a8-0f5a-457a-80ef-3f8cdf2ea58f,e3d7ac24-5fce-419e-9353-eb93adfa1530,3bca8ac3-a0e0-4931-80af-be584ba2a9a2,a3210650-f127-43e3-b5dd-0a22497c2d74,b0061ecb-5212-42cf-9622-42fa8b15821f,8c9a2496-033a-4907-a054-392f85e7acc0,47547486-1199-4ccc-91dc-3db65655b5e8,a5e4691d-25a6-4ca1-a7a4-8bb6d56dd64b,b027ff23-6934-4bc1-926c-f2d0853d2604,fa3fb2ab-9655-4bbb-af8e-b6a834518fc2,df3ec9f5-dd95-4d3b-a8db-ceb28fc8d82b,f8b4aa60-8f3f-44cf-9933-b577c75cbf35,93c12cad-9c31-4f68-8a74-637686944733,7626b647-8ea0-4423-b456-4dcb8b43023c,1db9f630-1753-4a07-8bd8-67668a7483e4,64fa53a8-47f8-4bc5-9244-d1ad1d330e02,1e58158d-43d4-4a4c-9034-23e56a10fa31,1ce92e09-955e-4c93-b456-631dd44efab0,6c092311-c552-4bdf-8c43-c42d39a54c29,419ef6b9-53f1-446c-8c98-381d2424fcbd,fb52a2e1-a64d-4f17-820f-dd328e5bd001,0dc8fd39-e2b4-4552-8f34-a95cd9898916,10b6dfea-8048-4bf6-a3fe-c5992ba7067e,b9630038-af3d-4de1-be13-7de68294806d,cb96c4ab-9304-47ef-834d-93ac5c63ed4e,6b623483-5a0b-4a3e-b57f-b1fdcca803ca,987d3dc3-5cea-4ffb-a4c9-b8601c1eff17,59bd3c0d-0abe-4eea-b55d-e2faad8520c1,19c89a4b-508c-411b-817a-ff0811af2c69,34c1e838-a647-45ce-8305-c90d674a73f8,dc454db2-2d43-4416-946e-6eb908bcbdb8,2b1c218c-3df8-451a-82a4-4b68a2d07dc3,f5c5c279-c167-4cac-8dbf-ee21068cff8b,45026e5a-b2b8-44e8-844c-f4f8f35beda8,1f48ef4e-c397-4325-8dae-1db4f26a9d97,bb7eda18-9df5-475a-a9fb-5d2a5c5e283d,1b5b56a4-99f4-4bb3-b65b-292947af56cc,f7b35d04-156b-43d9-9891-fa8756e500a2,c11e0a2d-69b6-4e7f-958d-171cec49add8,0aaedbea-9c77-426b-a4b1-74f1dabbe88a,29ba7823-4779-463f-8e0a-926240962e4d,3ba4ebef-2070-499a-ac06-ff1f086d720e,5a2ab204-ca23-407c-8416-a6bad9137135,7687b012-864c-4ac3-93f8-8ba7a45e6043,9a772cf1-2cf5-4eb2-b91d-8497c948eb3f,41ab8b5f-ee26-4c47-9b98-470e7a711202,cf9f1096-031e-437f-9028-a63181bf6a17,c87f5333-c3a5-43d8-bba8-9b2c60f27eaf,be726f42-caff-40eb-b22c-0987be254fb9,42b84653-6957-4f6b-b2a4-12a6bfb3b3d5,5676ac98-597a-4982-9816-4424f4f6cbe2,be1889fa-a4a6-464b-a7b9-725c0ddf8905,74577134-6d36-49bb-ad57-b5a35884431a,35d56626-a2b0-445b-81e8-d744b0c4d3cf,98a29469-0b89-4278-8f28-26aba04da4ec,c1dfd913-baef-45df-a23f-9fe96fd99af6,cfab0552-d3ac-403f-bf84-1a25f0093428,fea1e8af-0a09-41bc-a644-4a32f8ecce6d,819f5d4c-fbcb-4286-ade1-e0f9ea7167a0,9e6bd209-f131-460b-9375-21b1dae3077d,bc6962a4-a833-481f-ae1d-ffc9125f4a1d,124c2012-081d-4b57-a01b-8cd0f9a27199,1b2d0ca8-9531-403c-b0cf-070829880a2f,e27cd04f-34e5-468e-8ddb-95c47a2e6866,01eab85c-18f2-4e19-a189-c137af74dd8a,7d062088-dc96-46bb-a1d0-9430eaa632d8,653d6ff3-89f4-4f3f-a077-0c6e47900018,cd3e4c99-07c8-4395-b7c7-10d0c1f67799,457a22a2-63e4-4f24-af44-b46c00313cbc,ee6d8838-61b8-411b-b2eb-d60ce6ab06d4,b1c91813-a63b-4ea6-ac45-86dfa66e0f21,a064537e-0c62-47a1-9716-1ed6fc4623e9,c5ace890-0240-4d01-b583-b5d78081d153,148a5bba-3463-47d1-9e5c-c174b9c77a3a,0412e6db-7c9c-41bb-8e9d-5f295477d58c,49d13ebe-4368-4978-b0e6-fb60a6b253f5,ce7b2f88-3b4e-4038-a2b9-f244d31751b0,58b7ee29-19c8-4e28-beb7-615d0be8b673,12fd8e46-11f7-43a0-9eef-db7ab78fce2f,f3c3eeff-dc2e-4e84-b6a5-1c9d5c36ea95,48a835ae-94d6-45d3-80c6-38f4649bff5e,07490964-748d-42e2-88eb-efaad39438ff,cc22cfce-5d2b-42a2-890f-62b98f80e65b,aa35c1d6-aeb7-41c3-be32-ce016358c071,6b5f5286-8528-4ead-b0e4-d693676fad8e,8496ebfd-d8f4-4453-9dd1-3d3d797a0a3d,7e0dd6c1-2342-40f7-b4bc-d7cf2788ae49,2b5cf913-6b1a-452f-99c4-4a1776b2002b,99eb0da6-db07-48c3-bd20-d05f88ad16af,dd278799-6c20-4047-873d-f4ee3a6d89b3,142edb08-01c6-499d-9589-60e21537f07d,80cddb9d-7106-48e2-91ca-dbe31ddf3a6d,ab0b496f-0659-495d-ad3d-eb5274bdc73c,b8706baa-802a-4d6f-ad48-2483eb3f1440,1ac3cd49-6437-432a-b997-2f4e75d8e5f0,0ddd3ac9-dc29-4c91-b3be-f2b192f30c59,2717171e-55e3-448f-8247-ad28a14be218,f70628d1-9a18-488d-8964-2a3182b3fd2f,301367b7-8822-417a-b9d6-f3513907b2d4,2ae5b0b3-800f-4241-aee7-d9291f4435a1,c246b423-566e-4515-85f7-86483e18e53d,3fa747c7-00bb-481c-a0c1-86e15d8692d0,e8db0498-41e8-4bd5-a86e-d205529026e6,22f3197d-8afc-4c99-ba0f-5d56bdbb3ae7,74777228-5642-45d2-999a-e83b62290d4a,1c69e78b-cb6b-4376-b048-a4b38d6dea3f,0175a7b6-92de-4111-98aa-78df95dd9907,6e848c0f-baf2-4463-9df1-7583519ac876,8e1599f9-6b40-4618-a763-51df2ae45d33,4a74d124-89f0-43e8-be0f-7dd8e24c8fac,632f6669-e03e-4f95-b01a-e5ce3385209e,813625ff-34fc-4933-bcc0-55f7b6885b42,b29b651e-a445-43fd-8612-52db8c864c1b,70e23fec-716d-43b0-b2d5-ac7945984048,198bac49-43f4-412a-adfd-f312e1f7505f,8a3ab4b3-b626-4b40-b148-758b43808102,e4a1d651-bd68-401c-a259-f264844fc1cc,a4c27118-f05e-44d8-87ae-5f4ddd62290c,cfc9903e-9b86-42d0-a7ef-16bf18e4af9d,f17ac3a2-e933-4ae5-8d48-d364f61f2801,aac52dec-cee9-44ed-bb95-2eff0cc83a30,edbb2098-0bfa-49e5-b5f6-c6334b740e08,a1bfa9d5-0fe9-4475-9b9a-ccd77c1816f4,6adde47c-06ce-4ad8-9439-b69a5207dd71,3c4bc202-69be-4ce1-bbbb-f07444d3334c,095d439f-d97c-48b1-922a-789c0f4d8ae9,928261cf-9381-46d8-9789-5130272641f2,18aba55d-ce2d-4c40-8b63-87eb04790b32,b85910c9-29c1-476b-97e8-bc039c3c0e65,cce39982-76e6-40a3-8870-8ff4beafb612,8de78a50-0523-4eb1-82c9-e708aba48277,c9283d0e-4de3-4abf-b04b-0da95003c367,2cd8a238-bf55-4b10-b241-fa985a426c56,92ee3a99-87bc-4d4a-af89-354004b2f8c9,796c4341-1702-42c8-ba32-e1461e99177e,3a6a2639-9121-4f21-87fd-6ce70d4e0159,b7dd92c8-9d34-479c-89b0-959494bd5ebd,21180525-5d41-4b50-9d77-7d83cef4babb,4ffb1f7b-6957-420a-916b-585c948cc899,a7ef617a-bdda-4994-bbcd-4e0779cc86b9,86497e41-51c0-4e60-930d-69bcf7eab2c0,600c2490-d649-46c5-b037-2cba0b7e783b,3adccacc-252d-4551-bf9b-89db8dcea23c,082497c5-1263-4416-abfc-e094262345c2,36471d36-2df5-4976-81eb-20d188f100c5,2a1ee2fa-739f-43f2-bb79-10d8d469a5a9,e8d9dfeb-f872-43f4-87c6-a60728d9a4b9,35aeb77c-5591-4e49-8c5e-6a38f4ee3c0e,4f627370-59d4-4e93-a288-f76ce30b6226,9854721d-7cf3-47a4-90b8-56e148dfc694,f4af34dd-25a9-4bb3-b10e-e88b92ec66cf,cd8f2681-d0ae-4466-946d-a8a6e7b57ae9,598f8d62-0b34-4cbf-a4ae-91a9358f4e72,a5773c2f-21ff-4b4b-afb4-53a83a1f839f,539eb10f-a2da-4ecb-bbfc-fcc2aa9fa333,e75ef09a-d9b0-425a-bb07-663135024488,98db0e28-e8d8-4a1b-bb6c-4cfc9c645250,638aefe8-6cda-4eff-9e28-698eb8aa8982,b16a7ba1-6503-46e6-8b8e-2f2f83931d17,e179369c-203b-4b1e-9c11-ef4b00a96528,7fb2ea17-4f26-4d65-9209-f3f7d1c73a19,7552dd57-2e15-4980-80d9-10c9df5ed1c7,c38f5207-d209-4a14-a291-af9ddde69b4b,e32c0085-6ed0-486a-b67f-6f7b7f8af091,4f34516f-9674-4a60-9c33-5ff0a1b51e51,7c1c5408-e8be-4707-9c8c-7fec08434947,54268aac-e6e5-41c8-98b0-17594da54800,7b5c0116-2273-4c52-b70f-4a351a0b6da7,7b8e1d90-b3ce-4ad0-9d38-c1d917325f66,f72ab63a-054c-4711-9a26-555fb79da000,ef21feea-1e12-4ef8-a907-12f153443877,45f09b65-51e7-4a87-9208-2f5ed68d191f,80454355-5eba-4c0a-a0ae-bf5577e0b02f,ba02377a-e29c-42df-a014-67a10fa96ad9,4fed1fa8-618d-410f-b816-6f5a0b6e4438,b27f6819-17f9-4bad-b9d0-0fe8f0f7de0c,c1b7fcb5-7706-4bbb-855a-366f87d30311,3c004639-5cbb-4ce8-8c66-205474966343,9027b9c4-7e9a-400c-851a-cb051792e480,35b215b7-a306-4855-815a-c51a2b49c145,37211256-a2c5-4e81-a097-6f68d5795346,c1b7fcb5-7706-4bbb-855a-366f87d30311,32730cc7-44b1-4b15-b194-618180298cb0,c241e1a5-2eee-4364-95f1-b71b4623b93e,ce2ce819-9e63-4616-ba33-b67dac0322e0,ce33d728-de41-4e6b-8185-e2fa53bb44c4,7c8357a1-d79d-49f6-8377-710827a268b1,edd63ac8-58c0-48a6-a927-0cb7df2784bd,81b63c05-da35-4068-bef9-e7237d91e96f,ad4f86d0-cd02-43f4-a03e-487e1c074c7d,29430ba6-8e4d-4c86-9007-8a065fd835c1,b153e12c-e32d-4f83-b4ba-85dd6f1f223a,06548572-d8d6-44ed-bf45-b1f46cde50bc,699bf6c2-75eb-4337-a081-6c3b2ee4ca6e,b58349c3-77b6-40bf-b37e-067fe74e9f60,9d0a2340-fa0a-4465-9aff-4c7ffffb4f26,e50d4192-0406-4433-88c0-498ae4597158,42508f51-2369-473e-a942-69264b9cc1a2,df62b79e-3f51-4ed5-b994-aeb62ca4f7b7,337ad028-543d-4e40-a9ef-ae3d6be0186a,28763372-e0d3-4635-a492-ed089b991402,da875869-4064-48b2-bf13-a74bcfc0d55a,62ec0356-6178-4715-884b-cae70e2919f5,47969dba-26b8-4630-9565-2230a1972dc2,d3f7e359-dc50-42b1-b597-d8ee877ac3b9,e7a1c010-1d69-4e0c-9b54-9ad15d1b208c,59ed45f0-55c3-4aee-a077-18c42fa608dc,c1cfc077-773d-408b-b661-b08840d4ed52,a4501950-20be-44fa-a2fe-76c3d2b3d93d,6ad71f60-1669-4464-8e47-2ddf13141703,2811134c-6f50-4eed-8fc1-255930c4f0c9,b71baad1-1afc-4907-8284-77f9f3fe8e21,f9471887-158e-45bc-aea1-45ac4f06e8ac,429688ce-531e-4d6d-9d26-379b1270f4a2,fd820740-27b6-4911-90fb-33a8656054ba,16dbea8d-99bb-4f69-a701-93a3dfbd812b,92eb5723-39b8-492a-bad2-8613b1f8d847,784b2b91-3a04-4c4e-b524-22a86fea6720,2ae5b0b3-800f-4241-aee7-d9291f4435a1,064ccc5f-f6c5-49c7-8d8a-bd466614aa7a,c95a6305-8300-40f5-be20-e7c078e6ca53,442b1ac8-4aec-40f3-a829-c84282cc911f,8f3be91a-001b-413d-9d15-cc91ce079a6e,7809fb33-309f-49f5-82ac-87394758ce9d'
	----SET @gids = N'A58D9752-FB5D-4A72-A3D6-B5350006CF8A,F44FB45E-164C-451D-85D5-2ED7ED3F7ABA,BCD2D8EE-B5C5-46D6-AF71-EE9DB73EC7C0'
	--SET @gids = N'6daf8cb7-087f-4164-8037-94b42e3b8562,39365a7b-847f-49c6-a8f6-25e51c8ab8dd,5c3153c6-fa67-471b-8008-3122d35cfeed,bcd2d8ee-b5c5-46d6-af71-ee9db73ec7c0,3a316860-0c95-469a-a1da-241f6dc995fd,d495faa3-6ba0-44b2-a5fb-275a052253e7,f44fb45e-164c-451d-85d5-2ed7ed3f7aba,27b0d5df-bd7f-4dd6-9c19-f0bee7b8b772,818afd3a-dc45-4042-93fb-870472dffb0c,c7152466-0fb2-4c82-8b9c-f8a97af6bdbc,6daf8cb7-087f-4164-8037-94b42e3b8562,a58d9752-fb5d-4a72-a3d6-b5350006cf8a,9234e5e3-5df4-4857-84e6-aa2e4b7627c8,f1a53645-2b55-432c-b6fc-078443904106'
	--SET @date = '2017-10-18 00:00'
	--SET @edate = NULL --= '2017-10-20 23:59'
	--SET @uid = N'3db40c4a-7e79-4f41-8017-de6e12ec7a20'

	IF @edate IS NULL
	BEGIN
		SET @edate = DATEADD(SECOND, -1, DATEADD(DAY, 1, @date))
	END

	SELECT ka.KronosAbsenseId,
           ka.Date,
		   g.GroupId,
           ka.DriverId,
		   g.GroupName,
		   dbo.FormatDriverNameByUser(ka.DriverId, @uid) AS DriverName,
		   ka.KronosAbsenseTypeId,
           kat.Name,
		   ka.Duration,
           ka.Comment,
		   ka.UserId,
		   dbo.FormatUserNameByUser(ka.UserId, @uid) AS UserName
	FROM dbo.KronosAbsense ka
	INNER JOIN dbo.GroupDetail gd ON ka.DriverId = gd.EntityDataId
	INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	INNER JOIN dbo.KronosAbsenseType kat ON kat.KronosAbsenseTypeId = ka.KronosAbsenseTypeId
	WHERE ka.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
	  AND g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	  AND ka.Date BETWEEN @date AND @edate
	  AND ka.Archived = 0
	  AND kat.Archived = 0
	 and ka.[Date] is not NULL

	UNION --Get Group Totals
    
	SELECT NULL AS KronosAbsenseId,
           NULL AS Date,
		   g.GroupId,
           NULL AS DriverId,
		   g.GroupName,
		   NULL AS DriverName,
		   NULL AS KronosAbsenseTypeId,
           NULL AS Name,
		   ISNULL(SUM(ka.Duration), 0) AS Duration,
           NULL AS Comment,
		   NULL AS UserId,
		   NULL AS UserName
	FROM dbo.[Group] g
	INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
	LEFT JOIN dbo.Driver d ON gd.EntityDataId = d.DriverId
	LEFT JOIN dbo.KronosAbsense ka ON ka.DriverId = d.DriverId AND ka.Date BETWEEN @date AND @edate AND ka.Archived = 0	
	LEFT JOIN dbo.KronosAbsenseType kat ON kat.KronosAbsenseTypeId = ka.KronosAbsenseTypeId AND kat.Archived = 0
	WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
	  AND g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	 and [Date] is not NULL
	GROUP BY g.GroupId, g.GroupName

	UNION -- Get details for drivers with no Kronos absence records

	SELECT NULL AS KronosAbsenseId,
           NULL AS Date,
		   g.GroupId,
           d.DriverId,
		   g.GroupName,
		   dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
		   NULL AS KronosAbsenseTypeId,
           NULL AS Name,
		   NULL AS Duration,
           NULL AS Comment,
		   NULL AS UserId,
		   NULL AS UserName
	FROM dbo.Driver d
	INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
	INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	LEFT JOIN dbo.KronosAbsense ka ON ka.DriverId = d.DriverId AND ka.Date BETWEEN @date AND @edate AND ka.Archived = 0
	WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
	  AND ka.KronosAbsenseId IS NULL	
	  AND g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	  --AND [Date] is not NULL
	
	UNION --Get Fleet Totals
    
	SELECT NULL AS KronosAbsenseId,
           NULL AS Date,
		   NULL AS GroupId,
           NULL AS DriverId,
		   NULL AS GroupName,
		   NULL AS DriverName,
		   NULL AS KronosAbsenseTypeId,
           NULL AS Name,
		   ISNULL(SUM(ka.Duration), 0) AS Duration,
           NULL AS Comment,
		   NULL AS UserId,
		   NULL AS UserName
	FROM dbo.[Group] g
	INNER JOIN dbo.GroupDetail gd ON gd.GroupId = g.GroupId
	LEFT JOIN dbo.Driver d ON gd.EntityDataId = d.DriverId
	LEFT JOIN dbo.KronosAbsense ka ON ka.DriverId = d.DriverId AND ka.Date BETWEEN @date AND @edate AND ka.Archived = 0	
	LEFT JOIN dbo.KronosAbsenseType kat ON kat.KronosAbsenseTypeId = ka.KronosAbsenseTypeId AND kat.Archived = 0
	WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ','))
	  AND g.GroupId IN (SELECT Value FROM dbo.Split(@gids, ','))
	  AND [Date] is not NULL

	ORDER BY GroupName, DriverName    

GO
