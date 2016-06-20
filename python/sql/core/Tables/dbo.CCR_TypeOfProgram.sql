CREATE TABLE [dbo].[CCR_TypeOfProgram]
(
[TOP_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CCR_TypeOfProgram_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram] ADD CONSTRAINT [PK_CCR_TypeOfProgram] PRIMARY KEY CLUSTERED  ([TOP_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram] ADD CONSTRAINT [FK_CCR_TypeOfProgram_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CCR_TypeOfProgram] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CCR_TypeOfProgram] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_TypeOfProgram] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_TypeOfProgram] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CCR_TypeOfProgram] TO [cioc_login_role]
GO
