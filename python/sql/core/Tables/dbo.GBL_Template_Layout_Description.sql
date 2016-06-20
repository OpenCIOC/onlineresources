CREATE TABLE [dbo].[GBL_Template_Layout_Description]
(
[LayoutID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[LayoutName] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LayoutHTML] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LayoutHTMLURL] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[SystemLayoutCode] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Template_Layout_Description] ADD CONSTRAINT [PK_GBL_Template_Layout_Description] PRIMARY KEY CLUSTERED  ([LayoutID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Template_Layout_Description] ADD CONSTRAINT [FK_GBL_Template_Layout_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_Template_Layout_Description] ADD CONSTRAINT [FK_GBL_Template_Layout_Description_GBL_Template_Layout] FOREIGN KEY ([LayoutID]) REFERENCES [dbo].[GBL_Template_Layout] ([LayoutID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
