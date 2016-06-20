DECLARE @UPDATED_BASE TABLE (action varchar(20), DstPageName varchar(255), PageName varchar(255), CIC bit, VOL bit, CanOverrideTitle bit, UserVisible bit, HasPageHelpFile bit, NoPageHelp bit, NoPageMsg bit)

MERGE INTO GBL_PageInfo dst
USING cioc_setup_source.dbo.GBL_PageInfo src
ON src.PageName=dst.PageName COLLATE Latin1_General_100_CI_AI
WHEN MATCHED AND src.PageName<>dst.PageName COLLATE Latin1_General_100_CS_AS OR src.CIC<>dst.CIC OR src.VOL<>dst.VOL OR src.CanOverrideTitle<>dst.CanOverrideTitle or src.UserVisible<>dst.UserVisible or src.HasPageHelpFile<>dst.HasPageHelpFile or src.NoPageMsg<>dst.NoPageMsg THEN
	UPDATE
		SET 
			PageName = src.PageName,
			CREATED_DATE = src.CREATED_DATE,
			CREATED_BY = src.CREATED_BY,
			MODIFIED_DATE = src.MODIFIED_DATE,
			MODIFIED_BY = src.MODIFIED_BY,
			CIC = src.CIC,
			VOL = src.VOL,
			CanOverrideTitle = src.CanOverrideTitle,
			UserVisible = src.UserVisible,
			HasPageHelpFile = src.HasPageHelpFile,
			NoPageHelp = src.NoPageHelp,
			NoPageMsg = src.NoPageMsg

WHEN NOT MATCHED BY TARGET THEN
	INSERT (PageName, CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, CIC, VOL, CanOverrideTitle, UserVisible, HasPageHelpFile, NoPageHelp, NoPageMsg)
		VALUES (src.PageName, src.CREATED_DATE, src.CREATED_BY, src.MODIFIED_DATE, src.MODIFIED_BY, src.CIC, src.VOL, src.CanOverrideTitle, src.UserVisible, src.HasPageHelpFile, src.NoPageHelp, src.NoPageMsg)
		
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
	
OUTPUT $action, deleted.PageName, src.PageName, src.CIC, src.VOL, src.CanOverrideTitle, src.UserVisible, src.HasPageHelpFile, src.NoPageHelp, src.NoPageMsg
	INTO @UPDATED_BASE
	;
	
	
SELECT * FROM @UPDATED_BASE

DECLARE @UPDATED_DESCRIPTION TABLE (action varchar(20), DstPageName varchar(255), DstLangID smallint, PageName varchar(255), LangID smallint, PageTitle nvarchar(255), HelpFileName varchar(255), HelpFileRelease varchar(10)) 
	
MERGE INTO GBL_PageInfo_Description dst
USING cioc_setup_source.dbo.GBL_PageInfo_Description src
ON src.PageName=dst.PageName COLLATE Latin1_General_100_CI_AI AND src.LangID=dst.LangID
WHEN MATCHED AND src.PageName <> dst.PageName COLLATE Latin1_General_100_CS_AS
		OR ISNULL(src.PageTitle, '') <> ISNULL(dst.PageTitle, '') COLLATE Latin1_General_100_CS_AS 
		OR ISNULL(src.HelpFileName,'') <>ISNULL(dst.HelpFileName,'') COLLATE Latin1_General_100_CS_AS 
		OR ISNULL(src.HelpFileRelease,'') <> ISNULL(dst.HelpFileRelease,'') COLLATE Latin1_General_100_CS_AS THEN
	UPDATE
		SET PageName=src.PageName, PageTitle = src.PageTitle, HelpFileName = src.HelpFileName, HelpFileRelease=src.HelpFileRelease

WHEN NOT MATCHED BY TARGET THEN
	INSERT (PageName, LangID, PageTitle, HelpFileName, HelpFileRelease)
		VALUES (src.PageName, src.LangID, src.PageTitle, src.HelpFileName, src.HelpFileRelease)
		
WHEN NOT MATCHED BY SOURCE AND NULLIF(LTRIM(RTRIM(dst.TitleOverride)), '') IS NULL THEN
	DELETE
	
OUTPUT $action, deleted.PageName, deleted.LangID, src.PageName, src.LangID, src.PageTitle, src.HelpFileName, src.HelpFileRelease
	INTO @UPDATED_DESCRIPTION
	;
	
SELECT * FROM @UPDATED_DESCRIPTION