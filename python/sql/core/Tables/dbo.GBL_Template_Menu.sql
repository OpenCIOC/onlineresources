CREATE TABLE [dbo].[GBL_Template_Menu]
(
[MenuID] [int] NOT NULL IDENTITY(1, 1),
[Template_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Template_Menu_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Template_Menu_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MenuType] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Display] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Link] [varchar] (150) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Template_Menu_DisplayOrder] DEFAULT ((0)),
[MenuGroup] [tinyint] NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Template_Menu] ADD
CONSTRAINT [CK_GBL_Template_Menu_MenuGroup] CHECK (([MenuGroup] IS NULL OR [MenuGroup]>(0) AND [MenuGroup]<(4)))
GO
ALTER TABLE [dbo].[GBL_Template_Menu] ADD CONSTRAINT [CK_GBL_Template_Menu] CHECK (([DisplayOrder]>=(0)))
GO
ALTER TABLE [dbo].[GBL_Template_Menu] ADD CONSTRAINT [PK_GBL_Template_Menu] PRIMARY KEY CLUSTERED  ([MenuID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Template_Menu] ADD CONSTRAINT [FK_GBL_Template_Menu_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_Template_Menu] ADD CONSTRAINT [FK_GBL_Template_Menu_GBL_Template] FOREIGN KEY ([Template_ID]) REFERENCES [dbo].[GBL_Template] ([Template_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
