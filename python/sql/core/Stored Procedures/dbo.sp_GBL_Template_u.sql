SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Template_u]
	@Template_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@AgencyCode [char](3),
	@UseCIC [bit],
	@UseVOL [bit],
	@Owner [char](3),
	@BannerRepeat bit,
	@BannerHeight tinyint,
	@StyleSheetUrl varchar(150),
	@ExtraCSS nvarchar(MAX),
	@JavaScriptTopUrl varchar(150),
	@JavaScriptBottomUrl varchar(150),
	@ShortCutIcon varchar(150),
	@AppleTouchIcon varchar(150),
	@BodyTagExtras varchar(150),
	@Background varchar(150),
	@BackgroundColour varchar(7),
	@bgColorLogo varchar(7),
	@FontFamily varchar(100),
	@FontColour varchar(7),
	@HeaderLayout int,
	@FooterLayout int,
	@SearchLayoutCIC int,
	@SearchLayoutVOL int,
	@HeaderSearchLink bit,
	@HeaderSearchIcon bit,
	@HeaderSuggestLink bit,
	@HeaderSuggestIcon bit,
	@ContainerFluid bit,
	@ContainerContrast bit,
	@SmallTitle bit,
	@fcLabel varchar(7),
	@FieldLabelColour varchar(7),
	@LinkColour varchar(7),
	@ALinkColour varchar(7),
	@VLinkColour varchar(7),
	@fcTitle varchar(7),
	@bgColorTitle varchar(7),
	@borderColorTitle varchar(7),
	@iconColorTitle varchar(7),
	@fcContent varchar(7),
	@bgColorContent varchar(7),
	@borderColorContent varchar(7),
	@iconColorContent varchar(7),
	@fcHeader varchar(7),
	@bgColorHeader varchar(7),
	@borderColorHeader varchar(7),
	@iconColorHeader varchar(7),
	@fcFooter varchar(7),
	@bgColorFooter varchar(7),
	@borderColorFooter varchar(7),
	@iconColorFooter varchar(7),
	@fcMenu varchar(7),
	@bgColorMenu varchar(7),
	@borderColorMenu varchar(7),
	@iconColorMenu varchar(7),
	@fcDefault varchar(7),
	@bgColorDefault varchar(7),
	@borderColorDefault varchar(7),
	@iconColorDefault varchar(7),
	@fcHover varchar(7),
	@bgColorHover varchar(7),
	@borderColorHover varchar(7),
	@iconColorHover varchar(7),
	@fcActive varchar(7),
	@bgColorActive varchar(7),
	@borderColorActive varchar(7),
	@iconColorActive varchar(7),
	@fcHighlight varchar(7),
	@bgColorHighlight varchar(7),
	@borderColorHighlight varchar(7),
	@iconColorHighlight varchar(7),
	@AlertColour varchar(7),
	@fcError varchar(7),
	@bgColorError varchar(7),
	@borderColorError varchar(7),
	@iconColorError varchar(7),
	@fcInfo varchar(7),
	@bgColorInfo varchar(7),
	@borderColorInfo varchar(7),
	@iconColorInfo varchar(7),
	@cornerRadius varchar(10),
	@fsDefault varchar(10),
	@FullSSLCompatible bit,
	@UseFontAwesome bit,
	@PreviewTemplate bit,
	@MenuFontColour varchar(7),
	@MenuBgColour varchar(7),
	@TitleFontColour varchar(7),
	@TitleBgColour varchar(7),
	@Descriptions [xml],
	@MenuItems [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 02-May-2016
	Action: NO ACTION REQUIRED
*/


DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@DesignTemplateObjectName nvarchar(100),
		@LayoutObjectName nvarchar(100),
		@AgencyObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @DesignTemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Design Template')
SET @DesignTemplateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Template Layout')
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable table (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(150) NULL,
	Logo varchar(150) NULL,
	LogoAltText nvarchar(200) NULL,
	LogoLink varchar(150) NULL,
	LogoMobile varchar(150) NULL,
	Banner varchar(150) NULL,
	CopyrightNotice nvarchar(255) NULL,
	headerGroup1 nvarchar(100) NULL,
	headerGroup2 nvarchar(100) NULL,
	headerGroup3 nvarchar(100) NULL,
	footerGroup1 nvarchar(100) NULL,
	footerGroup2 nvarchar(100) NULL,
	footerGroup3 nvarchar(100) NULL,
	cicsearchGroup1 nvarchar(100) NULL,
	cicsearchGroup2 nvarchar(100) NULL,
	cicsearchGroup3 nvarchar(100) NULL,
	volsearchGroup1 nvarchar(100) NULL,
	volsearchGroup2 nvarchar(100) NULL,
	volsearchGroup3 nvarchar(100) NULL,
	Agency nvarchar(255) NULL,
	Address nvarchar(255) NULL,
	Phone nvarchar(255) NULL,
	Email nvarchar(150) NULL,
	Web varchar(150) NULL,
	Facebook varchar(150) NULL,
	Twitter varchar(150) NULL,
	Instagram varchar(150) NULL,
	LinkedIn varchar(150) NULL,
	YouTube varchar(150) NULL,
	TermsOfUseLink varchar(150) NULL,
	TermsOfUseLabel nvarchar(100) NULL,
	FooterNotice nvarchar(3000) NULL,
	FooterNotice2 nvarchar(2000) NULL,
	FooterNoticeContact nvarchar(2000) NULL,
	HeaderNotice nvarchar(2000) NULL,
	HeaderNoticeMobile nvarchar(1000) NULL
)

DECLARE @MenuTable table (
	MenuID int NULL,
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	MenuType varchar(10) NOT NULL,
	Display nvarchar(200) NOT NULL,
	Link varchar(150) NOT NULL,
	DisplayOrder tinyint NOT NULL,
	MenuGroup tinyint NULL
)

DECLARE @UsedNamesDesc nvarchar(MAX),
		@UsedNamesMenu nvarchar(MAX),
		@BadCulturesDesc nvarchar(MAX),
		@BadCulturesMenu nvarchar(MAX)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name,
	Logo,
	LogoAltText,
	LogoLink,
	LogoMobile,
	Banner,
	CopyrightNotice,
	headerGroup1,
	headerGroup2,
	headerGroup3,
	footerGroup1,
	footerGroup2,
	footerGroup3,
	cicsearchGroup1,
	cicsearchGroup2,
	cicsearchGroup3,
	volsearchGroup1,
	volsearchGroup2,
	volsearchGroup3,
	Agency,
	Address,
	Phone,
	Email,
	Web,
	Facebook,
	Twitter,
	Instagram,
	LinkedIn,
	YouTube,
	TermsOfUseLink,
	TermsOfUseLabel,
	FooterNotice,
	FooterNotice2,
	FooterNoticeContact,
	HeaderNotice,
	HeaderNoticeMobile
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Name[1]', 'nvarchar(150)') AS Name,
	N.value('Logo[1]', 'varchar(150)') AS Logo,
	N.value('LogoAltText[1]', 'nvarchar(200)') AS LogoAltText,
	N.value('LogoLink[1]', 'varchar(150)') AS LogoLink,
	N.value('LogoMobile[1]', 'varchar(150)') AS LogoMobile,
	N.value('Banner[1]', 'varchar(150)') AS Banner,
	N.value('CopyrightNotice[1]', 'varchar(150)') AS CopyrightNotice,
	N.value('headerGroup1[1]', 'nvarchar(100)') AS headerGroup1,
	N.value('headerGroup2[1]', 'nvarchar(100)') AS headerGroup2,
	N.value('headerGroup3[1]', 'nvarchar(100)') AS headerGroup3,
	N.value('footerGroup1[1]', 'nvarchar(100)') AS footerGroup1,
	N.value('footerGroup2[1]', 'nvarchar(100)') AS footerGroup2,
	N.value('footerGroup3[1]', 'nvarchar(100)') AS footerGroup3,
	N.value('cicsearchGroup1[1]', 'nvarchar(100)') AS cicsearchGroup1,
	N.value('cicsearchGroup2[1]', 'nvarchar(100)') AS cicsearchGroup2,
	N.value('cicsearchGroup3[1]', 'nvarchar(100)') AS cicsearchGroup3,
	N.value('volsearchGroup1[1]', 'nvarchar(100)') AS volsearchGroup1,
	N.value('volsearchGroup2[1]', 'nvarchar(100)') AS volsearchGroup2,
	N.value('volsearchGroup3[1]', 'nvarchar(100)') AS volsearchGroup3,
	N.value('Agency[1]', 'nvarchar(255)') AS Agency,
	N.value('Address[1]', 'nvarchar(255)') AS Address,
	N.value('Phone[1]', 'nvarchar(255)') AS Phone,
	N.value('Email[1]', 'varchar(150)') AS Email,
	N.value('Web[1]', 'varchar(150)') AS Web,
	N.value('Facebook[1]', 'varchar(150)') AS Facebook,
	N.value('Twitter[1]', 'varchar(150)') AS Twitter,
	N.value('Instagram[1]', 'varchar(150)') AS Instagram,
	N.value('LinkedIn[1]', 'varchar(150)') AS  LinkedIn,
	N.value('YouTube[1]', 'varchar(150)') AS YouTube,
	N.value('TermsOfUseLink[1]', 'nvarchar(150)') AS TermsOfUseLink,
	N.value('TermsOfUseLabel[1]', 'nvarchar(100)') AS TermsOfUseLabel,
	N.value('FooterNotice[1]', 'nvarchar(3000)') AS FooterNotice,
	N.value('FooterNotice2[1]', 'nvarchar(2000)') AS FooterNotice2,
	N.value('FooterNoticeContact[1]', 'nvarchar(2000)') AS FooterNoticeContact,
	N.value('HeaderNotice[1]', 'nvarchar(2000)') AS HeaderNotice,
	N.value('HeaderNoticeMobile[1]', 'nvarchar(1000)') AS HeaderNoticeMobile
FROM @Descriptions.nodes('//DESC') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg

INSERT INTO @MenuTable (
	MenuID,
	Culture,
	LangID,
	MenuType,
	Display,
	Link,
	DisplayOrder,
	MenuGroup
)
SELECT
	N.value('MenuID[1]', 'int') AS MenuID,
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('MenuType[1]', 'varchar(10)') AS MenuType,
	N.value('Display[1]', 'nvarchar(200)') AS Display,
	N.value('Link[1]', 'varchar(150)') AS Link,
	N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder,
	N.value('MenuGroup[1]', 'tinyint') AS MenuGroup
FROM @MenuItems.nodes('//MENU') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg

UPDATE @DescTable
	SET Name = (SELECT TOP 1 Name FROM @DescTable WHERE Name IS NOT NULL ORDER BY LangID)
WHERE Name IS NULL

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_Template t INNER JOIN GBL_Template_Description td ON t.Template_ID=td.Template_ID WHERE Name=nt.Name AND LangID=nt.LangID AND t.Template_ID<>@Template_ID AND (t.MemberID IS NULL OR t.MemberID=@MemberID))

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

SELECT @BadCulturesMenu = COALESCE(@BadCulturesMenu + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @MenuTable nt
WHERE LangID IS NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Template exists ?
END ELSE IF @Template_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@Template_ID AS varchar), @DesignTemplateObjectName)
-- Not a System Template ?
END ELSE IF EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID AND SystemTemplate=1) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('System Template'), NULL)
-- Template belongs to Member ?
END ELSE IF @Template_ID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Agency exists ?
END ELSE IF @Owner IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyCode=@Owner) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Owner, @AgencyObjectName)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND @Template_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Template WHERE Template_ID=@Template_ID AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DesignTemplateObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @DesignTemplateObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @DesignTemplateObjectName)
-- Name in use ?
END ELSE IF @UsedNamesDesc IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNamesDesc, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
-- Invalid language ?
END ELSE IF @BadCulturesMenu IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesMenu, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @Template_ID IS NULL BEGIN
		INSERT INTO GBL_Template (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			[Owner],
			BannerRepeat,
			BannerHeight,
			FullSSLCompatible,
			StyleSheetUrl,
			ExtraCSS,
			AppleTouchIcon,
			JavaScriptTopUrl,
			JavaScriptBottomUrl,
			ShortCutIcon,
			BodyTagExtras,
			Background,
			BackgroundColour,
			bgColorLogo,
			FontFamily,
			FontColour,
			fcLabel,
			FieldLabelColour,
			MenuFontColour,
			MenuBgColour,
			TitleFontColour,
			TitleBgColour,
			LinkColour,
			ALinkColour,
			VLinkColour,
			AlertColour,
			HeaderLayout,
			FooterLayout,
			SearchLayoutCIC,
			SearchLayoutVOL,
			HeaderSearchLink,
			HeaderSearchIcon,
			HeaderSuggestLink,
			HeaderSuggestIcon,
			ContainerFluid,
			ContainerContrast,
			SmallTitle,
			fcContent,
			bgColorContent,
			borderColorContent,
			iconColorContent,
			fcTitle,
			bgColorTitle,
			borderColorTitle,
			iconColorTitle,
			fcHeader,
			bgColorHeader,
			borderColorHeader,
			iconColorHeader,
			fcFooter,
			bgColorFooter,
			borderColorFooter,
			iconColorFooter,
			fcMenu,
			bgColorMenu,
			borderColorMenu,
			iconColorMenu,
			fcDefault,
			bgColorDefault,
			borderColorDefault,
			iconColorDefault,
			fcHover,
			bgColorHover,
			borderColorHover,
			iconColorHover,
			fcActive,
			bgColorActive,
			borderColorActive,
			iconColorActive,
			fcHighlight,
			bgColorHighlight,
			borderColorHighlight,
			iconColorHighlight,
			fcError,
			bgColorError,
			borderColorError,
			iconColorError,
			fcInfo,
			bgColorInfo,
			borderColorInfo,
			iconColorInfo,
			cornerRadius,
			fsDefault,
			UseFontAwesome,
			TemplateCSSVersionDate,
			PreviewTemplate
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@Owner,
			ISNULL(@BannerRepeat,1),
			@BannerHeight,
			@FullSSLCompatible,
			@StyleSheetUrl,
			@ExtraCSS,
			@AppleTouchIcon,
			@JavaScriptTopUrl,
			@JavaScriptBottomUrl,
			@ShortCutIcon,
			@BodyTagExtras,
			@Background,
			@BackgroundColour,
			@bgColorLogo,
			@FontFamily,
			@FontColour,
			@fcLabel,
			@FieldLabelColour,
			@MenuFontColour,
			@MenuBgColour,
			@TitleFontColour,
			@TitleBgColour,
			@LinkColour,
			@ALinkColour,
			@VLinkColour,
			@AlertColour,
			@HeaderLayout,
			@FooterLayout,
			CASE WHEN @UseCIC=1 THEN @SearchLayoutCIC ELSE (SELECT TOP 1 LayoutID FROM GBL_Template_Layout WHERE LayoutType='cicsearch' AND DefaultSearchLayout=1) END,
			CASE WHEN @UseVOL=1 THEN @SearchLayoutVOL ELSE (SELECT TOP 1 LayoutID FROM GBL_Template_Layout WHERE LayoutType='volsearch' AND DefaultSearchLayout=1) END,
			ISNULL(@HeaderSearchLink,1),
			ISNULL(@HeaderSearchIcon,0),
			ISNULL(@HeaderSuggestLink,0),
			ISNULL(@HeaderSuggestIcon,0),
			ISNULL(@ContainerFluid,1),
			ISNULL(@ContainerContrast,0),
			ISNULL(@SmallTitle,0),
			@fcContent,
			@bgColorContent,
			@borderColorContent,
			@iconColorContent,
			@fcTitle,
			@bgColorTitle,
			@borderColorTitle,
			@iconColorTitle,
			@fcHeader,
			@bgColorHeader,
			@borderColorHeader,
			@iconColorHeader,
			@fcFooter,
			@bgColorFooter,
			@borderColorFooter,
			@iconColorFooter,
			@fcMenu,
			@bgColorMenu,
			@borderColorMenu,
			@iconColorMenu,
			@fcDefault,
			@bgColorDefault,
			@borderColorDefault,
			@iconColorDefault,
			@fcHover,
			@bgColorHover,
			@borderColorHover,
			@iconColorHover,
			@fcActive,
			@bgColorActive,
			@borderColorActive,
			@iconColorActive,
			@fcHighlight,
			@bgColorHighlight,
			@borderColorHighlight,
			@iconColorHighlight,
			@fcError,
			@bgColorError,
			@borderColorError,
			@iconColorError,
			@fcInfo,
			@bgColorInfo,
			@borderColorInfo,
			@iconColorInfo,
			@cornerRadius,
			@fsDefault,
			@UseFontAwesome,
			GETDATE(),
			@PreviewTemplate
		)
		SELECT @Template_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE GBL_Template
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			Owner				= @Owner,
			BannerRepeat		= ISNULL(@BannerRepeat,BannerRepeat),
			BannerHeight		= @BannerHeight,
			StyleSheetUrl		= @StyleSheetUrl,
			ExtraCSS			= @ExtraCSS,
			JavaScriptTopUrl	= @JavaScriptTopUrl,
			JavaScriptBottomUrl	= @JavaScriptBottomUrl,
			ShortCutIcon		= @ShortCutIcon,
			AppleTouchIcon		= @AppleTouchIcon,
			BodyTagExtras		= @BodyTagExtras,
			Background			= @Background,
			BackgroundColour	= @BackgroundColour,
			bgColorLogo			= @bgColorLogo,
			FontFamily			= @FontFamily,
			FontColour			= @FontColour,
			HeaderLayout		= @HeaderLayout,
			FooterLayout		= @FooterLayout,
			SearchLayoutCIC		= CASE WHEN @UseCIC=1 THEN @SearchLayoutCIC ELSE SearchLayoutCIC END,
			SearchLayoutVOL		= CASE WHEN @UseVOL=1 THEN @SearchLayoutVOL ELSE SearchLayoutVOL END,
			HeaderSearchLink	= ISNULL(@HeaderSearchLink,HeaderSearchLink),
			HeaderSearchIcon	= ISNULL(@HeaderSearchIcon,HeaderSearchIcon),
			HeaderSuggestLink	= ISNULL(@HeaderSuggestLink,HeaderSuggestLink),
			HeaderSuggestIcon	= ISNULL(@HeaderSuggestIcon,HeaderSuggestIcon),
			ContainerFluid		= ISNULL(@ContainerFluid,ContainerFluid),
			ContainerContrast	= ISNULL(@ContainerContrast,ContainerContrast),
			SmallTitle			= ISNULL(@SmallTitle,SmallTitle),
			fcLabel				= @fcLabel,
			FieldLabelColour	= @FieldLabelColour,
			LinkColour			= @LinkColour,
			ALinkColour			= @ALinkColour,
			VLinkColour			= @VLinkColour,
			fcTitle				= @fcTitle,
			bgColorTitle		= @bgColorTitle,
			borderColorTitle	= @borderColorTitle,
			iconColorTitle		= @iconColorTitle,
			fcContent			= @fcContent,
			bgColorContent		= @bgColorContent,
			borderColorContent	= @borderColorContent,
			iconColorContent	= @iconColorContent,
			fcHeader			= @fcHeader,
			bgColorHeader		= @bgColorHeader,
			borderColorHeader	= @borderColorHeader,
			iconColorHeader		= @iconColorHeader,
			fcFooter			= @fcFooter,
			bgColorFooter		= @bgColorFooter,
			borderColorFooter	= @borderColorFooter,
			iconColorFooter		= @iconColorFooter,
			fcMenu				= @fcMenu,
			bgColorMenu			= @bgColorMenu,
			borderColorMenu		= @borderColorMenu,
			iconColorMenu		= @iconColorMenu,
			fcDefault			= @fcDefault,
			bgColorDefault		= @bgColorDefault,
			borderColorDefault	= @borderColorDefault,
			iconColorDefault	= @iconColorDefault,
			fcHover				= @fcHover,
			bgColorHover		= @bgColorHover,
			borderColorHover	= @borderColorHover,
			iconColorHover		= @iconColorHover,
			fcActive			= @fcActive,
			bgColorActive		= @bgColorActive,
			borderColorActive	= @borderColorActive,
			iconColorActive		= @iconColorActive,
			fcHighlight			= @fcHighlight,
			bgColorHighlight	= @bgColorHighlight,
			borderColorHighlight	= @borderColorHighlight,
			iconColorHighlight	= @iconColorHighlight,
			AlertColour			= @AlertColour,
			fcError				= @fcError,
			bgColorError		= @bgColorError,
			borderColorError	= @borderColorError,
			iconColorError		= @iconColorError,
			fcInfo				= @fcInfo,
			bgColorInfo			= @bgColorInfo,
			borderColorInfo		= @borderColorInfo,
			iconColorInfo		= @iconColorInfo,
			cornerRadius		= @cornerRadius,
			fsDefault			= @fsDefault,
			FullSSLCompatible	= @FullSSLCompatible,
			UseFontAwesome		= @UseFontAwesome,
			MenuFontColour		= @MenuFontColour,
			MenuBgColour		= @MenuBgColour,
			TitleFontColour		= @TitleFontColour,
			TitleBgColour		= @TitleBgColour,
			TemplateCSSVersionDate	= GETDATE(),
			PreviewTemplate	= @PreviewTemplate
		WHERE Template_ID = @Template_ID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
	

	IF @Error=0 AND @Template_ID IS NOT NULL BEGIN
		DELETE tld
		FROM GBL_Template_Description tld
		WHERE tld.Template_ID=@Template_ID
			AND NOT EXISTS(SELECT * FROM @DescTable nt WHERE tld.LangID=nt.LangID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
		
		UPDATE tld SET
			Name			= nt.Name,
			Logo			= nt.Logo,
			LogoAltText		= nt.LogoAltText,
			LogoLink		= nt.LogoLink,
			LogoMobile		= nt.LogoMobile,
			Banner			= nt.Banner,
			CopyrightNotice = nt.CopyrightNotice,
			headerGroup1	= nt.headerGroup1,
			headerGroup2	= nt.headerGroup2,
			headerGroup3	= nt.headerGroup3,
			footerGroup1	= nt.footerGroup1,
			footerGroup2	= nt.footerGroup2,
			footerGroup3	= nt.footerGroup3,
			cicsearchGroup1	= CASE WHEN @UseCIC = 1 THEN nt.cicsearchGroup1 ELSE tld.cicsearchGroup1 END,
			cicsearchGroup2	= CASE WHEN @UseCIC = 1 THEN nt.cicsearchGroup2 ELSE tld.cicsearchGroup2 END,
			cicsearchGroup3	= CASE WHEN @UseCIC = 1 THEN nt.cicsearchGroup3 ELSE tld.cicsearchGroup3 END,
			volsearchGroup1	= CASE WHEN @UseVOL = 1 THEN nt.volsearchGroup1 ELSE tld.volsearchGroup1 END,
			volsearchGroup2	= CASE WHEN @UseVOL = 1 THEN nt.volsearchGroup2 ELSE tld.volsearchGroup2 END,
			volsearchGroup3	= CASE WHEN @UseVOL = 1 THEN nt.volsearchGroup3 ELSE tld.volsearchGroup3 END,
			Agency			= nt.Agency,
			Address			= nt.Address,
			Phone			= nt.Phone,
			Email			= nt.Email,
			Web				= nt.Web,
			Facebook		= nt.Facebook,
			Twitter			= nt.Twitter,
			Instagram		= nt.Instagram,
			LinkedIn		= nt.LinkedIn,
			YouTube			= nt.YouTube,
			TermsOfUseLink	= nt.TermsOfUseLink,
			TermsOfUseLabel	= nt.TermsOfUseLabel,
			FooterNotice	= nt.FooterNotice,
			FooterNotice2	= nt.FooterNotice2,
			FooterNoticeContact = nt.FooterNoticeContact,
			HeaderNotice	= nt.HeaderNotice,
			HeaderNoticeMobile	= nt.HeaderNoticeMobile
		FROM GBL_Template_Description tld
		INNER JOIN @DescTable nt
			ON tld.LangID=nt.LangID
		WHERE tld.Template_ID=@Template_ID
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
	
		INSERT INTO GBL_Template_Description (
			Template_ID,
			LangID,
			Name,
			Logo,
			LogoAltText,
			LogoLink,
			LogoMobile,
			Banner,
			CopyrightNotice,
			headerGroup1,
			headerGroup2,
			headerGroup3,
			footerGroup1,
			footerGroup2,
			footerGroup3,
			cicsearchGroup1,
			cicsearchGroup2,
			cicsearchGroup3,
			volsearchGroup1,
			volsearchGroup2,
			volsearchGroup3,
			Agency,
			Address,
			Phone,
			Email,
			Web,
			Facebook,
			Twitter,
			Instagram,
			LinkedIn,
			YouTube,
			TermsOfUseLink,
			TermsOfUseLabel,
			FooterNotice,
			FooterNotice2,
			HeaderNotice,
			HeaderNoticeMobile
		) SELECT 
			@Template_ID,
			LangID,
			Name,
			Logo,
			LogoAltText,
			LogoLink,
			LogoMobile,
			Banner,
			CopyrightNotice,
			headerGroup1,
			headerGroup2,
			headerGroup3,
			footerGroup1,
			footerGroup2,
			footerGroup3,
			cicsearchGroup1,
			cicsearchGroup2,
			cicsearchGroup3,
			volsearchGroup1,
			volsearchGroup2,
			volsearchGroup3,
			Agency,
			Address,
			Phone,
			Email,
			Web,
			Facebook,
			Twitter,
			Instagram,
			LinkedIn,
			YouTube,
			TermsOfUseLink,
			TermsOfUseLabel,
			FooterNotice,
			FooterNotice2,
			HeaderNotice,
			nt.HeaderNoticeMobile
		FROM @DescTable nt
		WHERE NOT EXISTS(SELECT * FROM GBL_Template_Description WHERE Template_ID=@Template_ID AND LangID=nt.LangID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
		
		DELETE tmi
		FROM GBL_Template_Menu tmi
		WHERE tmi.Template_ID=@Template_ID
			AND NOT EXISTS(SELECT * FROM @MenuTable nt WHERE tmi.MenuID=nt.MenuID) AND NOT (tmi.MenuType = 'volsearch' AND @UseVOL=0) AND NOT (tmi.MenuType = 'cicsearch' AND @UseCIC=0)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
		
		UPDATE tmi SET
			Display			= nt.Display,
			Link			= nt.Link,
			DisplayOrder	= nt.DisplayOrder,
			MenuGroup		= nt.MenuGroup
		FROM GBL_Template_Menu tmi
		INNER JOIN @MenuTable nt
			ON tmi.MenuID=nt.MenuID
		WHERE tmi.Template_ID=@Template_ID AND NOT (tmi.MenuType = 'volsearch' AND @UseVOL=0) AND NOT (tmi.MenuType = 'cicsearch' AND @UseCIC=0)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
		
		INSERT INTO GBL_Template_Menu (
			Template_ID,
			LangID,
			MenuType,
			Display,
			Link,
			DisplayOrder,
			MenuGroup
		) SELECT 
			@Template_ID,
			LangID,
			MenuType,
			Display,
			Link,
			DisplayOrder,
			MenuGroup
		FROM @MenuTable nt
		WHERE nt.MenuID IS NULL AND NOT (nt.MenuType = 'volsearch' AND @UseVOL=0) AND NOT (nt.MenuType = 'cicsearch' AND @UseCIC=0)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DesignTemplateObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF








GO





















GRANT EXECUTE ON  [dbo].[sp_GBL_Template_u] TO [cioc_login_role]
GO
