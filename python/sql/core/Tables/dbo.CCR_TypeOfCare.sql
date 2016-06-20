CREATE TABLE [dbo].[CCR_TypeOfCare]
(
[TOC_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CCR_TypeOfCare_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfCare] ADD CONSTRAINT [PK_CCR_TypeOfCare] PRIMARY KEY CLUSTERED  ([TOC_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfCare] ADD CONSTRAINT [FK_CCR_TypeOfCare_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CCR_TypeOfCare] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CCR_TypeOfCare] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_TypeOfCare] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_TypeOfCare] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CCR_TypeOfCare] TO [cioc_login_role]
GO
