SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_SocialMedia_i]
	@NUM varchar(8),
	@HAS_ENGLISH bit,
	@HAS_FRENCH bit,
	@SocialMediaXML [xml],
	@BadTypes nvarchar(4000) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @LangTable TABLE (
	[LangID] smallint NOT NULL PRIMARY KEY
)

IF @HAS_ENGLISH=1 BEGIN
	INSERT INTO @LangTable (LangID) VALUES (0)
END
IF @HAS_FRENCH=1 BEGIN
	INSERT INTO @LangTable (LangID) VALUES (2)
END

DECLARE @SocialMediaTable TABLE (
	[TMPID] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[LangID] smallint NOT NULL,
	[Name] nvarchar(100) NOT NULL,
	[SM_ID] int NULL,
	[Protocol] varchar(10) NOT NULL,
	[URL] nvarchar(255) NOT NULL
)

INSERT INTO @SocialMediaTable (
	LangID,
	Name,
	Protocol,
	URL
)
SELECT
	CASE WHEN N.value('@LANG', 'char(1)') = 'F' THEN 2 WHEN N.value('@LANG', 'char(1)') = 'E' THEN 0 ELSE -1 END AS LangID,
	N.value('@NM', 'nvarchar(100)') AS Name,
	ISNULL(N.value('@PROTOCOL', 'varchar(10)'),'https://') AS Protocol,
	N.value('@URL', 'nvarchar(255)') AS URL
FROM @SocialMediaXML.nodes('//SOCIAL_MEDIA/TYPE') as T(N)

DELETE FROM @SocialMediaTable WHERE LangID NOT IN (SELECT * FROM @LangTable)

UPDATE smtm SET SM_ID=sm.SM_ID
	FROM @SocialMediaTable smtm
	INNER JOIN GBL_SocialMedia sm
		ON sm.DefaultName=smtm.Name AND sm.Active=1
		
SELECT @BadTypes = COALESCE(@BadTypes + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Name,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
	FROM @SocialMediaTable sm
WHERE SM_ID IS NULL
	OR EXISTS(SELECT * FROM @SocialMediaTable sm2 WHERE sm.SM_ID=sm2.SM_ID AND sm.LangID=sm2.LangID AND sm.TMPID < sm2.TMPID)

DELETE sm
	FROM @SocialMediaTable sm
WHERE SM_ID IS NULL OR EXISTS(SELECT * FROM @SocialMediaTable sm2 WHERE sm.SM_ID=sm2.SM_ID AND sm.LangID=sm2.LangID AND sm.TMPID < sm2.TMPID)

IF @HAS_ENGLISH=1 BEGIN
	MERGE INTO GBL_BT_SM pr
	USING @SocialMediaTable sm
		ON pr.NUM=@NUM AND pr.LangID=sm.LangID AND pr.SM_ID=sm.SM_ID
	WHEN MATCHED THEN
		UPDATE SET
			Protocol = sm.Protocol,
			URL = sm.URL
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (NUM, LangID, SM_ID, Protocol, URL)
			VALUES (@NUM, sm.LangID, sm.SM_ID, sm.Protocol, sm.URL)
	WHEN NOT MATCHED BY SOURCE AND pr.NUM=@NUM AND pr.LangID IN (SELECT * FROM @LangTable) THEN
		DELETE
		;
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_SocialMedia_i] TO [cioc_login_role]
GO
