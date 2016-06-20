CREATE TABLE [dbo].[VOL_Opportunity_History]
(
[HST_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[MODIFIED_DATE] [datetime] NOT NULL CONSTRAINT [DF_VOL_Opportunity_History_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[FieldID] [int] NOT NULL,
[FieldDisplay] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Opportunity_History_HSTIDVNUMLangID] ON [dbo].[VOL_Opportunity_History] ([HST_ID], [VNUM], [LangID]) WITH (FILLFACTOR=80) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Opportunity_History_MODIFIEDDATEHSTIDVNUMLangID] ON [dbo].[VOL_Opportunity_History] ([MODIFIED_DATE], [HST_ID], [VNUM], [LangID]) WITH (FILLFACTOR=80) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Opportunity_History_VNUMFieldIDHSTIDInclLangID] ON [dbo].[VOL_Opportunity_History] ([VNUM], [FieldID], [HST_ID]) INCLUDE ([LangID]) WITH (FILLFACTOR=80) ON [PRIMARY]

ALTER TABLE [dbo].[VOL_Opportunity_History] ADD 
CONSTRAINT [PK_VOL_Opportunity_History] PRIMARY KEY CLUSTERED  ([HST_ID]) ON [PRIMARY]






GO

ALTER TABLE [dbo].[VOL_Opportunity_History] ADD CONSTRAINT [FK_VOL_Opportunity_History_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Opportunity_History] ADD CONSTRAINT [FK_VOL_Opportunity_History_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Opportunity_History] ADD CONSTRAINT [FK_VOL_Opportunity_History_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Opportunity_History] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Opportunity_History] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Opportunity_History] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Opportunity_History] TO [cioc_vol_search_role]
GO
