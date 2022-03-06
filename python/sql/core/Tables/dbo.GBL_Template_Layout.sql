CREATE TABLE [dbo].[GBL_Template_Layout]
(
[LayoutID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Template_Layout_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Template_Layout_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[SystemLayout] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_Layout_SystemLayout] DEFAULT ((0)),
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[LayoutType] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[UseFontAwesome] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_Layout_UseFontAwesome] DEFAULT ((0)),
[UseFullCIOCBootstrap] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_Layout_UseFullCIOCBootstrap] DEFAULT ((0)),
[DefaultSearchLayout] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_Layout_DefaultSearchLayout] DEFAULT ((0)),
[LayoutCSS] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LayoutCSSURL] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[LayoutCSSVersionDate] [datetime] NOT NULL CONSTRAINT [DF_GBL_Template_Layout_VersionDate] DEFAULT (getdate()),
[AlmostStandardsMode] [bit] NOT NULL CONSTRAINT [DF_GBL_Template_Layout_AlmostStandardsMode] DEFAULT ((0)),
[SystemLayoutCode] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Template_Layout] ADD 
CONSTRAINT [PK_GBL_Template_Layout] PRIMARY KEY CLUSTERED  ([LayoutID]) ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Template_Layout_u] ON [dbo].[GBL_Template_Layout] 
FOR UPDATE AS

SET NOCOUNT ON

IF UPDATE(LayoutCSS) OR UPDATE(LayoutCSSURL) BEGIN
	UPDATE tl
			SET LayoutCSSVersionDate = GETDATE()
		FROM GBL_Template_Layout tl
		INNER JOIN Deleted d
			ON tl.LayoutID=d.LayoutID
		WHERE d.LayoutCSS<>tl.LayoutCSS OR d.LayoutCSSURL<>tl.LayoutCSSURL
		
	UPDATE t
		SET TemplateCSSVersionDate = GETDATE(),
		TemplateCSSLayoutURLs = dbo.fn_GBL_Template_SystemLayoutURLs(t.Template_ID)
	FROM GBL_Template t
	INNER JOIN Deleted d
		ON t.FooterLayout=d.LayoutID OR t.HeaderLayout=d.LayoutID OR t.SearchLayoutCIC=d.LayoutID OR t.SearchLayoutVOL=d.LayoutID
	INNER JOIN GBL_Template_Layout tl
		ON d.LayoutID=tl.LayoutID
	WHERE d.LayoutCSS<>tl.LayoutCSS OR d.LayoutCSSURL<>tl.LayoutCSSURL
END

IF UPDATE(AlmostStandardsMode) BEGIN	
	UPDATE t
		SET AlmostStandardsMode = CASE WHEN EXISTS(SELECT * FROM GBL_Template_Layout tl WHERE tl.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL) AND tl.AlmostStandardsMode=1) THEN 1 ELSE 0 END
	FROM GBL_Template t
	WHERE EXISTS(SELECT * FROM Inserted i WHERE i.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL))
END

IF UPDATE(UseFontAwesome) BEGIN
	UPDATE t
		SET UseFontAwesome_Cache = CASE
			WHEN t.UseFontAwesome=1 OR EXISTS(SELECT * FROM GBL_Template_Layout tl WHERE tl.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL) AND tl.UseFontAwesome=1)
			THEN 1 ELSE 0 END
	FROM GBL_Template t
	WHERE EXISTS(SELECT * FROM Inserted i WHERE i.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL))
END

IF UPDATE(UseFullCIOCBootstrap) BEGIN
	UPDATE t
		SET UseFullCIOCBootstrap_Cache = CASE
			WHEN EXISTS(SELECT * FROM GBL_Template_Layout tl WHERE tl.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL) AND tl.UseFullCIOCBootstrap=1)
			THEN 1 ELSE 0 END
	FROM GBL_Template t
	WHERE EXISTS(SELECT * FROM Inserted i WHERE i.LayoutID IN (t.FooterLayout, t.HeaderLayout, t.SearchLayoutCIC, t.SearchLayoutVOL))
END

SET NOCOUNT OFF
GO


ALTER TABLE [dbo].[GBL_Template_Layout] ADD
CONSTRAINT [CK_GBL_Template_Layout_SystemLayoutShared] CHECK (([MemberID] IS NOT NULL OR [SystemLayout]=(1)))
GO

ALTER TABLE [dbo].[GBL_Template_Layout] ADD CONSTRAINT [FK_GBL_Template_Layout_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_Template_Layout] ADD CONSTRAINT [FK_GBL_Template_Layout_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE SET NULL ON UPDATE CASCADE
GO
