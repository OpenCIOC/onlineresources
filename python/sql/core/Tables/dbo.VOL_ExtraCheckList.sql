CREATE TABLE [dbo].[VOL_ExtraCheckList]
(
[EXC_ID] [int] NOT NULL IDENTITY(1, 1),
[FieldName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_ExtraCheckList_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_ExtraCheckList_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_VOL_ExtraCheckList_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ExtraCheckList] ADD CONSTRAINT [PK_VOL_ExtraCheckList] PRIMARY KEY CLUSTERED  ([EXC_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_ExtraCheckList_EXCIDFieldName] ON [dbo].[VOL_ExtraCheckList] ([EXC_ID], [FieldName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ExtraCheckList] ADD CONSTRAINT [FK_VOL_ExtraCheckList_VOL_FieldOption] FOREIGN KEY ([FieldName]) REFERENCES [dbo].[VOL_FieldOption] ([FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_ExtraCheckList] ADD CONSTRAINT [FK_VOL_ExtraCheckList_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_ExtraCheckList] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_ExtraCheckList] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_ExtraCheckList] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_ExtraCheckList] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_ExtraCheckList] TO [cioc_vol_search_role]
GO
