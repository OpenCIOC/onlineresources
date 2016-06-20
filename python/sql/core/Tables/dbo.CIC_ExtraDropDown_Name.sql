CREATE TABLE [dbo].[CIC_ExtraDropDown_Name]
(
[EXD_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[FieldName_Cache] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_ExtraDropDown_Name_UniqueName] ON [dbo].[CIC_ExtraDropDown_Name] ([LangID], [Name], [FieldName_Cache]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_CIC_ExtraDropDown_Name_d] ON [dbo].[CIC_ExtraDropDown_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE exd
	FROM CIC_ExtraDropDown exd
	INNER JOIN Deleted d
		ON exd.EXD_ID=d.EXD_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_ExtraDropDown_Name exdn WHERE exdn.EXD_ID=exd.EXD_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_EXD pr WHERE pr.EXD_ID=exd.EXD_ID)
		AND exd.Code IS NOT NULL
	
SET NOCOUNT OFF

GO

ALTER TABLE [dbo].[CIC_ExtraDropDown_Name] ADD CONSTRAINT [PK_CIC_ExtraDropDown_Name] PRIMARY KEY CLUSTERED  ([EXD_ID], [LangID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CIC_ExtraDropDown_Name] ADD CONSTRAINT [FK_CIC_ExtraDropDown_Name_CIC_ExtraDropDown] FOREIGN KEY ([EXD_ID], [FieldName_Cache]) REFERENCES [dbo].[CIC_ExtraDropDown] ([EXD_ID], [FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExtraDropDown_Name] ADD CONSTRAINT [FK_CIC_ExtraDropDown_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_ExtraDropDown_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ExtraDropDown_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ExtraDropDown_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ExtraDropDown_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_ExtraDropDown_Name] TO [cioc_login_role]
GO
