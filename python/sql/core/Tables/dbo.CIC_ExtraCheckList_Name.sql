CREATE TABLE [dbo].[CIC_ExtraCheckList_Name]
(
[EXC_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[FieldName_Cache] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_ExtraCheckList_Name_UniqueName] ON [dbo].[CIC_ExtraCheckList_Name] ([LangID], [Name], [FieldName_Cache]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_CIC_ExtraCheckList_Name_d] ON [dbo].[CIC_ExtraCheckList_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE exc
	FROM CIC_ExtraCheckList exc
	INNER JOIN Deleted d
		ON exc.EXC_ID=d.EXC_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_ExtraCheckList_Name excn WHERE excn.EXC_ID=exc.EXC_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_EXC pr WHERE pr.EXC_ID=exc.EXC_ID)
		AND exc.Code IS NOT NULL
	
SET NOCOUNT OFF

GO

ALTER TABLE [dbo].[CIC_ExtraCheckList_Name] ADD CONSTRAINT [PK_CIC_ExtraCheckList_Name] PRIMARY KEY CLUSTERED  ([EXC_ID], [LangID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CIC_ExtraCheckList_Name] ADD CONSTRAINT [FK_CIC_ExtraCheckList_Name_CIC_ExtraCheckList] FOREIGN KEY ([EXC_ID], [FieldName_Cache]) REFERENCES [dbo].[CIC_ExtraCheckList] ([EXC_ID], [FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExtraCheckList_Name] ADD CONSTRAINT [FK_CIC_ExtraCheckList_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_ExtraCheckList_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ExtraCheckList_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ExtraCheckList_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ExtraCheckList_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_ExtraCheckList_Name] TO [cioc_login_role]
GO
