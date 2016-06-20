CREATE TABLE [dbo].[GBL_PageInfo]
(
[PageName] [varchar] (255) COLLATE Latin1_General_100_CS_AS NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_PageInfo_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_PageInfo_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CIC] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_CIC] DEFAULT ((0)),
[VOL] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_VOL] DEFAULT ((0)),
[CanOverrideTitle] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_CanOverrideTitle] DEFAULT ((0)),
[UserVisible] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_UserVisible] DEFAULT ((0)),
[Notes] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[HasPageHelpFile] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_HasPageHelpFile] DEFAULT ((0)),
[NoPageHelp] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_NoPageHelp] DEFAULT ((0)),
[NoPageMsg] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_NoPageMsg] DEFAULT ((0)),
[SearchResults] [bit] NOT NULL CONSTRAINT [DF_GBL_PageInfo_SearchResults] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_PageInfo_iu] ON [dbo].[GBL_PageInfo]
FOR INSERT, UPDATE AS 
BEGIN
	SET NOCOUNT ON

	IF UPDATE(PageName) OR UPDATE(CIC) OR UPDATE(VOL) OR UPDATE(UserVisible) OR UPDATE(Notes) BEGIN
		UPDATE pg
			SET MODIFIED_DATE = GETDATE(),
				MODIFIED_BY = 'CIOC HelpDesk'
		FROM GBL_PageInfo pg
		LEFT JOIN inserted i
			ON i.PageName=pg.PageName
		LEFT JOIN deleted d
			ON d.PageName=pg.PageName
		WHERE i.PageName IS NOT NULL OR d.PageName IS NOT NULL
	END

	SET NOCOUNT OFF
END
GO
ALTER TABLE [dbo].[GBL_PageInfo] ADD CONSTRAINT [CK_GBL_PageInfo_HasDomain] CHECK (([CIC]=(1) OR [VOL]=(1)))
GO
ALTER TABLE [dbo].[GBL_PageInfo] ADD CONSTRAINT [PK_GBL_PageInfo] PRIMARY KEY CLUSTERED  ([PageName]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_PageInfo] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_PageInfo] TO [cioc_login_role]
GO
