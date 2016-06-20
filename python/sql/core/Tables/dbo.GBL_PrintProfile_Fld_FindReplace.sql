CREATE TABLE [dbo].[GBL_PrintProfile_Fld_FindReplace]
(
[PFLD_RP_ID] [int] NOT NULL IDENTITY(1, 1),
[PFLD_ID] [int] NOT NULL,
[LookFor] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ReplaceWith] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[RunOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_Fld_FindReplace_RunOrder] DEFAULT ((0)),
[RegEx] [bit] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_Fld_FindReplace_RegularExpression] DEFAULT ((0)),
[MatchCase] [bit] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_Fld_FindReplace_IgnoreCase] DEFAULT ((1)),
[MatchAll] [bit] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_Fld_FindReplace_MatchAll] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_FindReplace] ADD CONSTRAINT [PK_GBL_PrintProfile_Fld_FindReplace] PRIMARY KEY CLUSTERED  ([PFLD_RP_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_FindReplace] WITH NOCHECK ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_FindReplace_GBL_PrintProfile_Fld] FOREIGN KEY ([PFLD_ID]) REFERENCES [dbo].[GBL_PrintProfile_Fld] ([PFLD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
