<%@LANGUAGE="VBSCRIPT"%>
<%Option Explicit%>

<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'      http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================

%>

<% 'Base includes %>
<!--#include file="../includes/core/adovbs.inc" -->
<!--#include file="../includes/core/incVBUtils.asp" -->
<!--#include file="../includes/validation/incBasicTypes.asp" -->
<!--#include file="../includes/core/incRExpFuncs.asp" -->
<!--#include file="../includes/core/incHandleError.asp" -->
<!--#include file="../includes/core/incSetLanguage.asp" -->
<!--#include file="../includes/core/incPassVars.asp" -->
<!--#include file="../text/txtGeneral.asp" -->
<!--#include file="../text/txtError.asp" -->
<!--#include file="../includes/core/incConnection.asp" -->
<!--#include file="../includes/core/incSetup.asp" -->
<%
' setPageInfo(bLogin, intDomain, intDbArea, strPathToStart, strPathFromStart, strFocus)
Call setPageInfo(True, DM_CIC, DM_CIC, vbNullString, vbNullString, vbNullString)
%>
<!--#include file="../includes/core/incCrypto.asp" -->
<!--#include file="../includes/core/incSecurity.asp" -->
<% 'End Base includes %>
<!--#include file="../text/txtGeneralForm.asp" -->
<!--#include file="../text/txtSearchAdvanced.asp" -->
<!--#include file="../text/txtSearchBasic.asp" -->
<!--#include file="../text/txtSearchBasicCIC.asp" -->
<!--#include file="../text/txtEntryForm.asp" -->
<!--#include file="../includes/search/incChecklistSearchForm.asp" -->
<% 'Common Lists %>
<!--#include file="../includes/list/incAccessibilityList.asp" -->
<!--#include file="../includes/list/incSocialMediaList.asp" -->
<% 'CIC Lists %>
<!--#include file="../includes/list/incAccreditationList.asp" -->
<!--#include file="../includes/list/incBusRouteList.asp" -->
<!--#include file="../includes/list/incCertificationList.asp" -->
<!--#include file="../includes/list/incCommList.asp" -->
<!--#include file="../includes/list/incCurrencyList.asp" -->
<!--#include file="../includes/list/incDistList.asp" -->
<!--#include file="../includes/list/incExtraCheckListList.asp" -->
<!--#include file="../includes/list/incExtraDropDownList.asp" -->
<!--#include file="../includes/list/incFeeTypeList.asp" -->
<!--#include file="../includes/list/incFiscalYearEndList.asp" -->
<!--#include file="../includes/list/incFundingList.asp" -->
<!--#include file="../includes/list/incLanguagesList.asp" -->
<!--#include file="../includes/list/incMappingSystemList.asp" -->
<!--#include file="../includes/list/incMembershipTypeList.asp" -->
<!--#include file="../includes/list/incOrgLocationServiceList.asp" -->
<!--#include file="../includes/list/incPaymentMethodList.asp" -->
<!--#include file="../includes/list/incPaymentTermsList.asp" -->
<!--#include file="../includes/list/incQualityList.asp" -->
<!--#include file="../includes/list/incRecordTypeList.asp" -->
<!--#include file="../includes/list/incSchoolList.asp" -->
<!--#include file="../includes/list/incServiceLevelList.asp" -->
<!--#include file="../includes/list/incTypeOfCareList.asp" -->
<!--#include file="../includes/list/incTypeOfProgramList.asp" -->
<!--#include file="../includes/list/incWardList.asp" -->
<% 'VOL Lists %>
<!--#include file="../includes/list/incInterestList.asp" -->
<!--#include file="../includes/list/incCommitmentLengthList.asp" -->
<!--#include file="../includes/list/incInteractionLevelList.asp" -->
<!--#include file="../includes/list/incSeasonsList.asp" -->
<!--#include file="../includes/list/incSkillList.asp" -->
<!--#include file="../includes/list/incSuitabilityList.asp" -->
<!--#include file="../includes/list/incTrainingList.asp" -->
<!--#include file="../includes/list/incTransportationList.asp" -->

<%
'Set response type headers
Response.ContentType = "application/json"
Response.CacheControl = "Private"
Response.Expires=-1

Call run_response_callbacks()

Class BusRouteFormatter
	Function format_name(rs)
		With rs
			format_name = IIf(Nl(.Fields("RouteNumber")),vbNullString,"(" & .Fields("RouteNumber") & ")") & _
					IIf(Nl(.Fields("RouteName")),vbNullString," " & .Fields("RouteName"))
		End With
	End Function
End Class

Class DistFormatter
	Function format_name(rs)
		With rs
			format_name = .Fields("DistCode") & _
					IIf(Nl(.Fields("DistName")),vbNullString," - " & .Fields("DistName")) 
		End With
	End Function
End Class

Class SchoolFormatter
	Function format_name(rs)
		With rs
			format_name = .Fields("SchoolName") & IIf(Nl(.Fields("SchoolBoard")),vbNullString," (" & .Fields("SchoolBoard") & ")")
		End With
	End Function
End Class

Class WardFormatter
	Function format_name(rs)
		With rs
			format_name = StringIf(Not Nl(.Fields("WardName")),.Fields("WardName") & " (") & _
					StringIf(Not Nl(.Fields("Municipality")),.Fields("Municipality") & " ") & TXT_WARD & " " & _
					.Fields("WardNumber") & StringIf(Not Nl(.Fields("WardName")),")")
		End With
	End Function
End Class

Sub PageContent()
	Dim strChecklistType, bError, objFormatter
	strChecklistType = Trim(Request("ChkType"))
	bError = False
	Select Case strChecklistType
	' CIC and VOL
		Case "ac"
			Call openAccessibilityListRst(False,False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("AccessibilityType")
			Response.Write(makeChecklistUI("ACType", "ACID", "ACIDx", True, rsListAccessibility, "AC_ID", objFormatter, True))
			Call closeAccessibilityListRst()
		Case "sm"
			Call openSocialMediaListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("SocialMediaName")
			Response.Write(makeChecklistUI("SMType", "SMID", "SMIDx", True, rsListSocialMedia, "SM_ID", objFormatter, True))
			Call closeSocialMediaListRst()
	' CIC
		Case "acr"
			Call openAccreditationListRst(False,False,Null)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("Accreditation")
			Response.Write(makeChecklistUI("ACRType", "ACRID", "ACRIDx", False, rsListAccreditation, "ACR_ID", objFormatter, True))
			Call closeAccreditationListRst()
		Case "br"
			Call openBusRouteListRst(False)
			Response.Write(makeChecklistUI("BRType", "BRID", "BRIDx", True, rsListBusRoute, "BR_ID", New BusRouteFormatter, True))
			Call closeBusRouteListRst()
		Case "cm"
			Call openCommListRst()
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("Community")
			Response.Write(makeChecklistUI("ECMType", "ECMID", "ECMIDx", True, rsListComm, "CM_ID", objFormatter, True))
			Call closeCommListRst()
		Case "crt"
			Call openCertificationListRst(False,False,Null)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("Certification")
			Response.Write(makeChecklistUI("CRTType", "CRTID", "CRTIDx", False, rsListCertification, "CRT_ID", objFormatter, True))
			Call closeCertificationListRst()
		Case "cur"
			Call openCurrencyListRst(False)
			Set objFormatter = New CodeAndNameFormatter
			Call objFormatter.setFields("Currency", "CurrencyName", False)
			Response.Write(makeChecklistUI("CURType", "CURID", "CURIDx", True, rsListCurrency, "CUR_ID", objFormatter, True))
			Call closeCurrencyListRst()
		Case "dst"
			Call openDistListRst(False)
			Response.Write(makeChecklistUI("DSTType", "DSTID", "DSTIDx", True, rsListDist, "DST_ID", New DistFormatter, True))
			Call closeDistListRst()
		Case "ft"
			Call openFeeTypeListRst(False,False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("FeeType")
			Response.Write(makeChecklistUI("FTType", "FTID", "FTIDx", True, rsListFeeType, "FT_ID", objFormatter, True))
			Call closeFeeTypeListRst()
		Case "fd"
			Call openFundingListRst(False,False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("FundingType")
			Response.Write(makeChecklistUI("FDType", "FDID", "FDIDx", True, rsListFunding, "FD_ID", objFormatter, True))
			Call closeFundingListRst()
		Case "fye"
			Call openFiscalYearEndListRst(False,False,Null)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("FiscalYearEnd")
			Response.Write(makeChecklistUI("FYEType", "FYEID", "FYEIDx", False, rsListFiscalYearEnd, "FYE_ID", objFormatter, True))
			Call closeFiscalYearEndListRst()
		Case "lcm"
			Call openCommListRst()
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("Community")
			Response.Write(makeChecklistUI("ELCMType", "ELCMID", "ELCMIDx", False, rsListComm, "CM_ID", objFormatter, True))
			Call closeCommListRst()
		Case "ln"
			Call openLanguagesListRst(False, False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("LanguageName")
			Response.Write(makeChecklistUI("LNType", "LNID", "LNIDx", True, rsListLanguages, "LN_ID", objFormatter, True))
			Call closeLanguagesListRst()
		Case "map"
			Call openMappingSystemListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("MappingSystemName")
			Response.Write(makeChecklistUI("MAPType", "MAPID", "MAPIDx", True, rsListMappingSystem, "MAP_ID", objFormatter, True))
			Call closeMappingSystemListRst()
		Case "mt"
			Call openMembershipTypeListRst(False,False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("MembershipType")
			Response.Write(makeChecklistUI("MTType", "MTID", "MTIDx", True, rsListMembershipType, "MT_ID", objFormatter, True))
			Call closeMembershipTypeListRst()
		Case "ols"
			Call openOrgLocationServiceListRst()
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("OrgLocationService")
			Response.Write(makeChecklistUI("OLSType", "OLSID", "OLSIDx", True, rsListOrgLocationService, "OLS_ID", objFormatter, True))
			Call closeOrgLocationServiceListRst()
		Case "pay"
			Call openPaymentMethodListRst(False,False,Null)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("PaymentMethod")
			Response.Write(makeChecklistUI("PAYType", "PAYID", "PAYIDx", False, rsListPaymentMethod, "PAY_ID", objFormatter, True))
			Call closePaymentMethodListRst()
		Case "pyt"
			Call openPaymentTermsListRst(False,False,Null)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("PaymentTerms")
			Response.Write(makeChecklistUI("PYTType", "PYTID", "PYTIDx", False, rsListPaymentTerms, "PYT_ID", objFormatter, True))
			Call closePaymentTermsListRst()
		Case "rq"
			Call openQualityListRst(False,Null)
			Set objFormatter = New CodeAndNameFormatter
			Call objFormatter.setFields("Quality", "QualityName", True)
			Response.Write(makeChecklistUI("RQType", "RQID", "RQIDx", False, rsListQuality, "Quality", objFormatter, True))
			Call closeQualityListRst()
		Case "rt"
			Call openRecordTypeListRst(False,False,False,Null)
			Set objFormatter = New CodeAndNameFormatter
			Call objFormatter.setFields("RecordType", "RecordTypeName", True)
			Response.Write(makeChecklistUI("RTType", "RTID", "RTIDx", False, rsListRecordType, "RecordType", objFormatter, True))
			Call closeRecordTypeListRst()
		Case "sche"
			Call openSchoolListRst(False)
			Response.Write(makeChecklistUI("SCHEType", "SCHEID", "SCHEIDx", True, rsListSchool, "SCH_ID", New SchoolFormatter, True))
			Call closeSchoolListRst()
		Case "scha"
			Call openSchoolListRst(False)
			Response.Write(makeChecklistUI("SCHAType", "SCHAID", "SCHAIDx", True, rsListSchool, "SCH_ID", New SchoolFormatter, True))
			Call closeSchoolListRst()
		Case "sl"
			Call openServiceLevelListRst(False)
			Set objFormatter = New CodeAndNameFormatter
			Call objFormatter.setFields("ServiceLevelCode", "ServiceLevel", True)
			Response.Write(makeChecklistUI("SLType", "SLID", "SLIDx", True, rsListServiceLevel, "SL_ID", objFormatter, True))
			Call closeServiceLevelListRst()
		Case "toc"
			Call openTypeOfCareListRst(False,False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("TypeOfCare")
			Response.Write(makeChecklistUI("TOCType", "TOCID", "TOCIDx", True, rsListTypeOfCare, "TOC_ID", objFormatter, True))
			Call closeTypeOfCareListRst()
		Case "top"
			Call openTypeOfProgramListRst(False,False,Null)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("TypeOfProgram")
			Response.Write(makeChecklistUI("TOPType", "TOPID", "TOPIDx", False, rsListTypeOfProgram, "TOP_ID", objFormatter, True))
			Call closeTypeOfProgramListRst()
		Case "wd"
			Call openWardListRst(False,Null)
			Response.Write(makeChecklistUI("WDType", "WDID", "WDIDx", False, rsListWard, "WD_ID", New WardFormatter, True))
			Call closeWardListRst()
	' VOL
		Case "ai"
			Call openInterestListRst(vbNullString, False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("InterestName")
			Response.Write(makeChecklistUI("AIType", "AIID", "AIIDx", True, rsListInterest, "AI_ID", objFormatter, True))
			Call closeInterestListRst()
		Case "cl"
			Call openCommitmentLengthListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("CommitmentLength")
			Response.Write(makeChecklistUI("CLType", "CLID", "CLIDx", True, rsListCommitmentLength, "CL_ID", objFormatter, True))
			Call closeCommitmentLengthListRst()
		Case "il"
			Call openInteractionLevelListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("InteractionLevel")
			Response.Write(makeChecklistUI("ILType", "ILID", "ILIDx", True, rsListInteractionLevel, "IL_ID", objFormatter, True))
			Call closeInteractionLevelListRst()
		Case "ssn"
			Call openSeasonsListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("Season")
			Response.Write(makeChecklistUI("SSNType", "SSNID", "SSNIDx", True, rsListSeasons, "SSN_ID", objFormatter, True))
			Call closeSeasonsListRst()
		Case "sb"
			Call openSuitabilityListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("SuitableFor")
			Response.Write(makeChecklistUI("SBType", "SBID", "SBIDx", True, rsListSuitability, "SB_ID", objFormatter, True))
			Call closeSuitabilityListRst()
		Case "sk"
			Call openSkillListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("Skill")
			Response.Write(makeChecklistUI("SKType", "SKID", "SKIDx", True, rsListSkill, "SK_ID", objFormatter, True))
			Call closeSkillListRst()
		Case "trn"
			Call openTrainingListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("TrainingType")
			Response.Write(makeChecklistUI("TRNType", "TRNID", "TRNIDx", True, rsListTraining, "TRN_ID", objFormatter, True))
			Call closeTrainingListRst()
		Case "trp"
			Call openTransportationListRst(False)
			Set objFormatter = New BasicFormatter
			Call objFormatter.setNameField("TransportationType")
			Response.Write(makeChecklistUI("TRPType", "TRPID", "TRPIDx", True, rsListTransportation, "TRP_ID", objFormatter, True))
			Call closeTransportationListRst()
		Case Else
			Dim strExtraPrefix, strFieldName
			strExtraPrefix = "E" & Mid(UCase(strChecklistType), 2)
			strFieldName = Mid(strExtraPrefix, 4)
			Select Case Left(strChecklistType, 3)
			Case "exc"
				strFieldName = "EXTRA_CHECKLIST_" & strFieldName
				Call openExtraCheckListListRst(DM_S_CIC, strFieldName, False, False)
				Set objFormatter = New BasicFormatter
				Call objFormatter.setNameField("ExtraCheckList")
				Response.Write(makeChecklistUI(strExtraPrefix & "Type", strExtraPrefix & "ID", strExtraPrefix & "IDx", True, dicRsListExtraCheckList(strFieldName), "EXC_ID", objFormatter, True))
				Call closeExtraCheckListListRst(strFieldName)
			Case "exd"
				strFieldName = "EXTRA_DROPDOWN_" & strFieldName
				Call openExtraDropDownListRst(DM_S_CIC, strFieldName, False, False, vbNullString)
				Set objFormatter = New BasicFormatter
				Call objFormatter.setNameField("ExtraDropDown")
				Response.Write(makeChecklistUI(strExtraPrefix & "Type", strExtraPrefix & "ID", strExtraPrefix & "IDx", True, dicRsListExtraDropDown(strFieldName), "EXD_ID", objFormatter, True))
				Call closeExtraDropDownListRst(strFieldName)
			Case "vxc"
				strFieldName = "EXTRA_CHECKLIST_" & strFieldName
				Call openExtraCheckListListRst(DM_S_VOL, strFieldName, False, False)
				Set objFormatter = New BasicFormatter
				Call objFormatter.setNameField("ExtraCheckList")
				Response.Write(makeChecklistUI(strExtraPrefix & "Type", strExtraPrefix & "ID", strExtraPrefix & "IDx", True, dicRsListExtraCheckList(strFieldName), "EXC_ID", objFormatter, True))
				Call closeExtraCheckListListRst(strFieldName)
			Case "vxd"
				strFieldName = "EXTRA_DROPDOWN_" & strFieldName
				Call openExtraDropDownListRst(DM_S_VOL, strFieldName, False, False, vbNullString)
				Set objFormatter = New BasicFormatter
				Call objFormatter.setNameField("ExtraDropDown")
				Response.Write(makeChecklistUI(strExtraPrefix & "Type", strExtraPrefix & "ID", strExtraPrefix & "IDx", True, dicRsListExtraDropDown(strFieldName), "EXD_ID", objFormatter, True))
				Call closeExtraDropDownListRst(strFieldName)
			Case Else
				bError = True
				%>
				{ "fail": true, "errinfo": <%=JSONQs(TXT_INVALID_CODE & strChecklistType, True)%> }
				<%
			End Select
	End Select
End Sub

Call PageContent()
%>

<!--#include file="../includes/core/incClose.asp" -->


