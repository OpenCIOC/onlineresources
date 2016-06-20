CREATE TABLE [dbo].[GBL_PaymentMethod]
(
[PAY_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_PaymentMethod_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentMethod] ADD CONSTRAINT [PK_GBL_PaymentMethod] PRIMARY KEY CLUSTERED  ([PAY_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PaymentMethod] ADD CONSTRAINT [FK_GBL_PaymentMethod_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_PaymentMethod] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_PaymentMethod] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_PaymentMethod] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_PaymentMethod] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_PaymentMethod] TO [cioc_login_role]
GO
