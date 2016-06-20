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

<%
Const JTYPE_AND = 0
Const JTYPE_OR = 1
Const JTYPE_BOOLEAN = 2

Const REXP_SQUOT = "\'"
Const REXP_DQUOT = "\"""
Const REXP_BEFORE_QUOT = "[\*\?%]*(\b|\S)([^"
Const REXP_AFTER_QUOT = "])*(\b|\S)[\*\?%]*"

Sub splitNonQTerms(strTerms, _
		ByRef singleTermStrs(), ByRef intSTerms, _
		ByRef quotedTermStrs(), ByRef intQTerms, _
		ByRef exactTermStrs(), ByRef intETerms, _
		ByRef displayTermStrs(), ByRef intDTerms _
		)

	Dim aTmpTerms, aETmpTerms, indTerm, i
	
	Call splitTerms(strTerms,False,aTmpTerms)
	Call splitTerms(strTerms,True,aETmpTerms)
	
	ReDim Preserve displayTermStrs(UBound(displayTermStrs) + UBound(aTmpTerms) + 1)
	For Each indTerm In aTmpTerms
		intDTerms = intDTerms + 1
		displayTermStrs(intDTerms) = indTerm
		
		If Not (reEquals(indTerm,"[""\*\s]",True,True,False,False) _ 
			Or (reEquals(indTerm,"\-",True,True,False,False) And g_objCurrentLang.LangID = LANG_FRENCH) _
			Or (reEquals(indTerm,"\'",True,True,False,False) And Not (g_objCurrentLang.LangID = LANG_ENGLISH And reEquals(indTerm,"\'s$",True,True,False,False))) _
			) Then
				intSTerms = intSTerms + 1
				ReDim Preserve singleTermStrs(intSTerms)
				singleTermStrs(intSTerms) = "FORMSOF(INFLECTIONAL," & Left(indTerm,250) & ")"
		Else
			intQTerms = intQTerms + 1
			ReDim Preserve quotedTermStrs(intQTerms)
			quotedTermStrs(intQTerms) = Left(indTerm,250)
		End If
	Next
	
	ReDim Preserve exactTermStrs(UBound(exactTermStrs) + UBound(aETmpTerms) + 1)
	For Each indTerm In aETmpTerms
		intETerms = intETerms + 1
		exactTermStrs(intETerms) = Left(Replace(indTerm,"*",vbNullString),250)
	Next
End Sub

Public Sub makeSearchString(strTerm, ByRef singleTermStrs(), ByRef quotedTermStrs(), ByRef exactTermStrs(), ByRef displayTermStrs(), bAllowKeywords)

	Dim rExp, eMatch, eMatches
	Set rExp = New RegExp

	strNewTerms = fixNastyCharacters(strTerm, bAllowKeywords)
	strNewTerms = padBrackets(strNewTerms)

	' get rid of double quotes
	rExp.Global = True
	rExp.Pattern = "(" & REXP_SQUOT & "){2,}"
	strNewTerms = rExp.Replace(strNewTerms,SQUOTE)
	rExp.Pattern = "(" & REXP_DQUOT & "){2,}"
	strNewTerms = rExp.Replace(strNewTerms,DQUOTE)

	' regex for separating out quoted phrases
	rExp.IgnoreCase = True
	rExp.Global = False
	rExp.Pattern = "(\s|^)(" & _
				REXP_SQUOT & REXP_BEFORE_QUOT & REXP_SQUOT & REXP_AFTER_QUOT & REXP_SQUOT & _
				")|(" & _
				REXP_DQUOT & REXP_BEFORE_QUOT & REXP_DQUOT & REXP_AFTER_QUOT & REXP_DQUOT & _
				")(\s|$)"

	Dim intSTerms, _
		intQTerms, _
		intETerms, _
		intDTerms

	Dim strNewTerms, _
		strPreTerms, _
		strQMatch

	Dim bReTest

	Dim intFromPos, intToPos

	bReTest = True
	intSTerms = -1
	intQTerms = -1
	intETerms = -1
	intDTerms = -1
	
	ReDim displayTermStrs(intQTerms)
	ReDim singleTermStrs(intSTerms)
	ReDim quotedTermStrs(intQTerms)
	ReDim exactTermStrs(intETerms)

	Do While bReTest
		Set eMatches = rExp.Execute(strNewTerms)
		If eMatches.Count > 0 Then
			Set eMatch = eMatches.Item(0)
			strQMatch = Trim(eMatch.Value)
			intFromPos = eMatch.FirstIndex
			intToPos = eMatch.FirstIndex + eMatch.Length
			
			'all terms before quoted phrase
			strPreTerms = Left(strNewTerms,intFromPos)
			
			Call splitNonQTerms(strPreTerms, _
				singleTermStrs, intSTerms, _
				quotedTermStrs, intQTerms, _
				exactTermStrs, intETerms, _
				displayTermStrs, intDTerms _
			)

			'all terms after quoted phrase
			strNewTerms = Right(strNewTerms,Len(strNewTerms)-intToPos)
			
			strQMatch = fixWildCards(strQMatch)
			strQMatch = Mid(strQMatch,2,Len(strQMatch)-2)
			strQMatch = Trim(fixQuotes(strQMatch))
			
			intETerms = intETerms + 1
			ReDim Preserve exactTermStrs(intETerms)
			exactTermStrs(intETerms) = DQUOTE & strQMatch & DQUOTE
			
			If isStop(strQMatch) Then
				strQMatch = Null
			End If
			
			If Not Nl(strQMatch) Then
				intQTerms = intQTerms + 1
				intDTerms = intDTerms + 1
				
				ReDim Preserve quotedTermStrs(intQTerms)
				ReDim Preserve displayTermStrs(intDTerms)
				
				quotedTermStrs(intQTerms) = DQUOTE & strQMatch & DQUOTE
				displayTermStrs(intDTerms) = quotedTermStrs(intQTerms)
			End If
		Else
			bReTest = False
		End If
	Loop
	
	Call splitNonQTerms(strNewTerms, _
		singleTermStrs, intSTerms, _
		quotedTermStrs, intQTerms, _
		exactTermStrs, intETerms, _
		displayTermStrs, intDTerms _
	)

End Sub

Private Function padBrackets(strTerm)
	strTerm = reReplace(strTerm, "\(([^\s])","( $1",False,False,True,False)
	strTerm = reReplace(strTerm, "([^\s])\)","$1 )",False,False,True,False)
	padBrackets = strTerm
End Function

Private Function fixWildcards(strTerm)
	Dim rExp, eMatches, eMatch, intFromPos, intToPos
	Set rExp = New RegExp

	Dim strNewTerms
	strNewTerms = strTerm
	
	strNewTerms = Replace(strNewTerms,"%","*")

	rExp.IgnoreCase = True
	rExp.Global = True

	rExp.Pattern = "(\*){2,}"
	strNewTerms = rExp.Replace(strNewTerms,"*")
	rExp.Pattern = "\S\*\S"
	Set eMatches = rExp.Execute(strNewTerms)
	If eMatches.Count > 0 Then
		Set eMatch = eMatches.Item(0)
		intFromPos = eMatch.FirstIndex
		intToPos = eMatch.FirstIndex + eMatch.Length
		strNewTerms = Left(strNewTerms,intFromPos+1) & Right(strNewTerms,Len(strNewTerms)-(intToPos-1))
	End If
	
	fixWildCards = strNewTerms
End Function

Private Function fixNastyCharacters(strTerm, bAllowSQLSpecial)
	Dim rExp
	Set rExp = New RegExp

	Dim strNewTerms
	strNewTerms = strTerm

	rExp.IgnoreCase = True
	rExp.Global = True

	If bAllowSQLSpecial Then
		rExp.Pattern = "[\+!;:|&\[\]\\\/]"
	Else
		rExp.Pattern = "[\+\(\),!;:|&\[\]\\\/~]"
	End If
	strNewTerms = rExp.Replace(strNewTerms," ")

	fixNastyCharacters = strNewTerms
End Function

Private Function fixQuotes(strTerm)
	Dim rExp
	Set rExp = New RegExp

	Dim strNewTerms
	strNewTerms = strTerm

	strNewTerms = Replace(strNewTerms,""""," ")

	rExp.IgnoreCase = True
	rExp.Global = True
	rExp.Pattern = "(\s|^)(" & REXP_SQUOT & ")+(\s|$)"

	Do While rExp.Test(strNewTerms)
		strNewTerms = rExp.Replace(strNewTerms," ")
	Loop

	strNewTerms = Replace(strNewTerms,SQUOTE,SQUOTE & SQUOTE)
	
	fixQuotes = strNewTerms
End Function

Private Sub splitTerms(ByVal strTerm, bForExactMatch, ByRef aTerms)
	Dim strNewTerms, intUBTerms, i, j, bRemoved
	strNewTerms = Trim(fixQuotes(strTerm))
	strNewTerms = fixWildCards(strNewTerms)
	strNewTerms = reReplace(strNewTerms,"\s+"," ",True,False,True,False)
	aTerms = Split(strNewTerms," ")

	If IsArray(aTerms) Then
		intUBTerms = UBound(aTerms)
		i = 0
		Do While i <= intUBTerms
			aTerms(i) = Trim(aTerms(i))
			If aTerms(i) = "" Or ((isReserved(aTerms(i)) Or isStop(aTerms(i))) And Not bForExactMatch) Then
				bRemoved = True
				intUBTerms = intUBTerms - 1
				For j = i to intUBTerms
					aTerms(j) = aTerms(j+1)
				Next
			Else
				If isSpecial(aTerms(i)) And Not bForExactMatch Then
					aTerms(i) = """" & aTerms(i) & """"
				End If
				i = i + 1
			End If
		Loop
	End If
	
	If bRemoved Then
		ReDim Preserve aTerms(intUBTerms)
	End If

End Sub

Private Function isSpecial(x)
	Dim strSpecial, strPartSpecial

	strPartSpecial = "[*]"
	If reEquals(x,strPartSpecial,True,False,False,False) Then
		isSpecial = True
		Exit Function
	End If

	strSpecial = "(near)|(weight)"
	If reEquals(x,strSpecial,True,True,True,False) Then
		isSpecial = True
		Exit Function
	End If

	isSpecial = False
End Function

Private Function isStop(x)
	Dim strStop

	strStop = "((\$)|(\_)|(-)" & _
		"|(ait)|(au)|(aux)|(avec)|(ce)|(ces)|(cet)|(cette)|(ceux)|(da)|(dans)|(de)|(des)|(du)|(dû)|(en)|(es)|(et)|(eu)|(il)|(ils)|(je)|(la)|(le)|(les)|(là)|(ma)|(me)|(mes)|(moi)|(na)|(ne)|(ni)|(on)" & _
		"|(ont)|(ou)|(où)|(par)|(pas)|(pour)|(qui)|(sa)|(se)|(si)|(surt)|(ta)|(te)|(tu)|(un)|(une)|(va)|(vs)|(vu)|(ça)|(çà)|(ès)" & _
		"|(an)|(and)|(are)|(as)|(at)|(if)|(in)|(is)|(of)|(on)|(or)|(the)|(to)|(with))"
	If reEquals(x,strStop,True,True,True,False) Then
		isStop = True
		Exit Function
	End If
End Function

Private Function isReserved(x)
	Dim strReserved

	strReserved = "(and)|(or)|(not)|(with)|(formsof)|(isabout)|(inflectional)"
	If reEquals(x,strReserved,True,True,True,False) Then
		isReserved = True
		Exit Function
	End If

	isReserved = False
End Function
%>
