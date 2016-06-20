CREATE TABLE [dbo].[GBL_Template_Layout_Type]
(
[LayoutType] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Template_Layout_Type] ADD CONSTRAINT [PK_GBL_Template_Layout_Type] PRIMARY KEY CLUSTERED  ([LayoutType]) ON [PRIMARY]
GO
