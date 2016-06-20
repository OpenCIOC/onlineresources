CREATE TABLE [dbo].[VOL_ExtraDropDown_Name]
(
[EXD_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[FieldName_Cache] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[tr_VOL_ExtraDropDown_Name_d] ON [dbo].[VOL_ExtraDropDown_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE exd
	FROM VOL_ExtraDropDown exd
	INNER JOIN Deleted d
		ON exd.EXD_ID=d.EXD_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_ExtraDropDown_Name exdn WHERE exdn.EXD_ID=exd.EXD_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_EXD pr WHERE pr.EXD_ID=exd.EXD_ID)
		AND exd.Code IS NOT NULL
	
SET NOCOUNT OFF


GO
ALTER TABLE [dbo].[VOL_ExtraDropDown_Name] ADD CONSTRAINT [PK_VOL_ExtraDropDown_Name] PRIMARY KEY CLUSTERED  ([EXD_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_ExtraDropDown_Name_UniqueName] ON [dbo].[VOL_ExtraDropDown_Name] ([LangID], [Name], [FieldName_Cache]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ExtraDropDown_Name] ADD CONSTRAINT [FK_VOL_ExtraDropDown_Name_VOL_ExtraDropDown] FOREIGN KEY ([EXD_ID], [FieldName_Cache]) REFERENCES [dbo].[VOL_ExtraDropDown] ([EXD_ID], [FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_ExtraDropDown_Name] ADD CONSTRAINT [FK_VOL_ExtraDropDown_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[VOL_ExtraDropDown_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_ExtraDropDown_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_ExtraDropDown_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_ExtraDropDown_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_ExtraDropDown_Name] TO [cioc_vol_search_role]
GO
