<!doctype html>
<%doc>
=========================================================================================
 Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
=========================================================================================
</%doc>

<html><head>
<%doc>
<script>
  function subst() {
    var vars={};
    var x=window.location.search.substring(1).split('&');
    for (var i in x) {var z=x[i].split('=',2);vars[z[0]] = unescape(z[1]);}
    var x=['frompage','topage','page','webpage','section','subsection','subsubsection'];
    for (var i in x) {
      var y = document.getElementsByClassName(x[i]);
      for (var j=0; j<y.length; ++j) y[j].textContent = vars[x[i]];
    }
  }
  </script>
</%doc>
</head><body style="border:0; margin: 0;"> 
## onload="subst()">
	<table style="border-top: 1px solid black; width: 100%">
		<tr>
			%if request.template_values['CopyrightNotice']:
			<td class="copyright">&copy; ${request.template_values['CopyrightNotice']|n}</td>
			%endif
			<td style="${'text-align:right' if request.template_values['CopyrightNotice'] else ''}">
				<a href="${srcurl}">${srcurl}</a><br>
			</td>
		</tr>
		%if request.viewdata.dom and request.viewdata.dom.PDFBottomMessage:
		<tr>
			<td colspan="2">
				${request.viewdata.dom.PDFBottomMessage|n}
			</td>
		</tr>
		%endif
	</table>
</body></html>
