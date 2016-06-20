CREATE TABLE [dbo].[CIC_ExtraDropDown]
(
[EXD_ID] [int] NOT NULL IDENTITY(1, 1),
[FieldName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_ExtraDropDown_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_ExtraDropDown_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_ExtraDropDown_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExtraDropDown] ADD CONSTRAINT [PK_CIC_ExtraDropDown] PRIMARY KEY CLUSTERED  ([EXD_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_ExtraDropDown_EXDIDFieldName] ON [dbo].[CIC_ExtraDropDown] ([EXD_ID], [FieldName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExtraDropDown] ADD CONSTRAINT [FK_CIC_ExtraDropDown_GBL_FieldOption] FOREIGN KEY ([FieldName]) REFERENCES [dbo].[GBL_FieldOption] ([FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExtraDropDown] ADD CONSTRAINT [FK_CIC_ExtraDropDown_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_ExtraDropDown] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ExtraDropDown] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ExtraDropDown] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ExtraDropDown] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_ExtraDropDown] TO [cioc_login_role]
GO
