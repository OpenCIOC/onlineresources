CREATE TABLE [dbo].[GBL_Template]
(
[Template_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[SystemTemplate] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_SystemTemplate] DEFAULT ((0)),
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[BannerRepeat] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_BannerRepeat] DEFAULT ((1)),
[BannerHeight] [tinyint] NULL,
[StyleSheetUrl] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[ExtraCSS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[JavaScriptTopUrl] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[JavaScriptBottomUrl] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[ShortCutIcon] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[AppleTouchIcon] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[BodyTagExtras] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[Background] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[BackgroundColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_BackgroundColour] DEFAULT ('#FFFFFF'),
[bgColorLogo] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorLogo] DEFAULT ('#ffffff'),
[FontFamily] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[FontColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_FontColour] DEFAULT ('#000000'),
[HeaderLayout] [int] NULL,
[FooterLayout] [int] NULL,
[SearchLayoutCIC] [int] NULL,
[SearchLayoutVOL] [int] NULL,
[HeaderSearchLink] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderSearchLink] DEFAULT ((1)),
[HeaderSearchIcon] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderSearchIcon] DEFAULT ((0)),
[HeaderSuggestLink] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderSuggestLink] DEFAULT ((0)),
[HeaderSuggestIcon] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderSuggestIcon] DEFAULT ((0)),
[HeaderSwitchLink] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderSwitchLink] DEFAULT ((0)),
[HeaderSwitchIcon] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderSwitchIcon] DEFAULT ((0)),
[HeaderLangLink] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderLangLink] DEFAULT ((0)),
[HeaderLangIcon] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_HeaderLangIcon] DEFAULT ((0)),
[SearchLabelWideCIC] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_SearchLabelWide] DEFAULT ((0)),
[ContainerContrast] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_ContainerContrast] DEFAULT ((0)),
[ContainerFluid] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_ContainerFluid] DEFAULT ((0)),
[BreadcrumbBar] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_BreadcrumbBar] DEFAULT ((1)),
[SmallTitle] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_SmallTitle] DEFAULT ((0)),
[fcLabel] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcLabel] DEFAULT ('#222222'),
[FieldLabelColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_FieldLabelColour] DEFAULT ('#F0F0F0'),
[LinkColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_LinkColour] DEFAULT ('#666666'),
[ALinkColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_ALinkColour] DEFAULT ('#999999'),
[VLinkColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_VLinkColour] DEFAULT ('#666666'),
[fcTitle] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_TitleFontColour1] DEFAULT ('#222222'),
[bgColorTitle] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_TitleBgColour1] DEFAULT ('#efefef'),
[borderColorTitle] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorTitle1] DEFAULT ('#CFCFCF'),
[iconColorTitle] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_MenuIconColour1_1] DEFAULT ('#CFCFCF'),
[fcContent] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcContent] DEFAULT ('#222222'),
[bgColorContent] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorContent] DEFAULT ('#ffffff'),
[borderColorContent] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorContent] DEFAULT ('#aaaaaa'),
[iconColorContent] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorContent] DEFAULT ('#222222'),
[fcHeader] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcHeader] DEFAULT ('#222222'),
[bgColorHeader] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorHeader] DEFAULT ('#cccccc'),
[borderColorHeader] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorHeader] DEFAULT ('#aaaaaa'),
[iconColorHeader] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorHeader] DEFAULT ('#222222'),
[fcFooter] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcHeader1] DEFAULT ('#222222'),
[bgColorFooter] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorHeader1] DEFAULT ('#cccccc'),
[borderColorFooter] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorFooter1] DEFAULT ('#aaaaaa'),
[iconColorFooter] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorHeader1] DEFAULT ('#222222'),
[fcMenu] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcDefault1] DEFAULT ('#555555'),
[bgColorMenu] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorDefault1] DEFAULT ('#e6e6e6'),
[borderColorMenu] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorDefault1] DEFAULT ('#d3d3d3'),
[iconColorMenu] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorDefault1] DEFAULT ('#888888'),
[fcDefault] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcDefault] DEFAULT ('#555555'),
[bgColorDefault] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorDefault] DEFAULT ('#e6e6e6'),
[borderColorDefault] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorDefault] DEFAULT ('#d3d3d3'),
[iconColorDefault] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorDefault] DEFAULT ('#888888'),
[fcHover] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcHover] DEFAULT ('#212121'),
[bgColorHover] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorHover] DEFAULT ('#dadada'),
[borderColorHover] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorHover] DEFAULT ('#999999'),
[iconColorHover] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorHover] DEFAULT ('#454545'),
[fcActive] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcActive] DEFAULT ('#212121'),
[bgColorActive] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorActive] DEFAULT ('#ffffff'),
[borderColorActive] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorActive] DEFAULT ('#aaaaaa'),
[iconColorActive] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorActive] DEFAULT ('#454545'),
[fcHighlight] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcHighlight] DEFAULT ('#363636'),
[bgColorHighlight] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorHighlight] DEFAULT ('#fbf9ee'),
[borderColorHighlight] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorHighlight] DEFAULT ('#fcefa1'),
[iconColorHighlight] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorHighlight] DEFAULT ('#2e83ff'),
[AlertColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_AlertColour] DEFAULT ('#FF0000'),
[fcError] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcError] DEFAULT ('#cd0a0a'),
[bgColorError] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorError] DEFAULT ('#fef1ec'),
[borderColorError] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorError] DEFAULT ('#cd0a0a'),
[iconColorError] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorError] DEFAULT ('#cd0a0a'),
[fcInfo] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fcError1] DEFAULT ('#212121'),
[bgColorInfo] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_bgColorError1] DEFAULT ('#fef1ec'),
[borderColorInfo] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_borderColorError1] DEFAULT ('#cd0a0a'),
[iconColorInfo] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_iconColorError1] DEFAULT ('#cd0a0a'),
[cornerRadius] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_cornerRadius] DEFAULT ('8px'),
[fsDefault] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_fsDefault] DEFAULT ('1em'),
[TemplateCSSVersionDate] [datetime] NULL CONSTRAINT [DF_GBL_Template_TemplateCSSVersionDate] DEFAULT (getdate()),
[TemplateCSSLayoutURLs] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AlmostStandardsMode] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_AlmostStandardsMode] DEFAULT ((1)),
[UseFullCIOCBootstrap_Cache] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_UseFullCIOCBootstrap] DEFAULT ((0)),
[UseFontAwesome] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_UseFontAwesome] DEFAULT ((0)),
[UseFontAwesome_Cache] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_UseFontAwesome_Cache] DEFAULT ((0)),
[SASSOveride] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MenuFontColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_MenuFontColour] DEFAULT ('#333333'),
[MenuBgColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_MenuBgColour] DEFAULT ('#CFCFCF'),
[TitleFontColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_TitleFontColour] DEFAULT ('#F0F0F0'),
[TitleBgColour] [varchar] (7) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_Template_TitleBgColour] DEFAULT ('#333333'),
[PreviewTemplate] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_PreviewTemplate] DEFAULT ((0)),
[ExtraJavascript] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Template_u] ON [dbo].[GBL_Template] 
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF UPDATE(HeaderLayout) OR UPDATE(FooterLayout) OR UPDATE(SearchLayoutCIC) OR UPDATE(SearchLayoutVOL) BEGIN		
	UPDATE t SET
		TemplateCSSLayoutURLs = dbo.fn_GBL_Template_SystemLayoutURLs(t.Template_ID),
		UseFontAwesome_Cache = CASE
			WHEN t.UseFontAwesome=1 OR EXISTS(SELECT * FROM GBL_Template_Layout tl WHERE tl.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL) AND tl.UseFontAwesome=1)
			THEN 1 ELSE 0 END,
		UseFullCIOCBootstrap_Cache = CASE
			WHEN EXISTS(SELECT * FROM GBL_Template_Layout tl WHERE tl.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL) AND tl.UseFullCIOCBootstrap=1)
			THEN 1 ELSE 0 END
	FROM GBL_Template t
	INNER JOIN Inserted i
		ON t.Template_ID=i.Template_ID

END

SET NOCOUNT OFF
GO

ALTER TABLE [dbo].[GBL_Template] ADD 
CONSTRAINT [PK_GBL_Template] PRIMARY KEY CLUSTERED  ([Template_ID]) ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Template] ADD
CONSTRAINT [CK_GBL_Template_SystemTemplateShared] CHECK (([MemberID] IS NOT NULL OR [SystemTemplate]=(1)))
GO






ALTER TABLE [dbo].[GBL_Template] ADD CONSTRAINT [FK_GBL_Template_GBL_Template_Layout_Footer] FOREIGN KEY ([FooterLayout]) REFERENCES [dbo].[GBL_Template_Layout] ([LayoutID])
GO
ALTER TABLE [dbo].[GBL_Template] ADD CONSTRAINT [FK_GBL_Template_GBL_Template_Layout_Header] FOREIGN KEY ([HeaderLayout]) REFERENCES [dbo].[GBL_Template_Layout] ([LayoutID])
GO
ALTER TABLE [dbo].[GBL_Template] ADD CONSTRAINT [FK_GBL_Template_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_Template] ADD CONSTRAINT [FK_GBL_Template_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Template] ADD CONSTRAINT [FK_GBL_Template_GBL_Template_Layout_SearchCIC] FOREIGN KEY ([SearchLayoutCIC]) REFERENCES [dbo].[GBL_Template_Layout] ([LayoutID])
GO
ALTER TABLE [dbo].[GBL_Template] ADD CONSTRAINT [FK_GBL_Template_GBL_Template_Layout_SearchVOL] FOREIGN KEY ([SearchLayoutVOL]) REFERENCES [dbo].[GBL_Template_Layout] ([LayoutID])
GO
