#!/bin/bash
# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================


USAGE="Usage: $0 user:pass site1 site2 ... siteN"

if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

LOGIN="$1"
shift 

if [ -z "$1" ]; then 
	SITES=fizban-current
else
	SITES="$@"
fi

TABLES="CIC_BT_TAX CIC_BT_TAX_TM GBL_COMMUNITY GBL_LANGUAGE TAX_RELATEDCONCEPT TAX_SEEALSO TAX_TERM TAX_TM_RC TAX_UNUSED THS_EQUIVALENT THS_SUBJECT THS_SBJ_BROADERTERM THS_SBJ_RELATEDTERM THS_SBJ_RELATEDTERM THS_SBJ_USEINSTEAD ORGINFOS  GEO ORGNAMES"

for table in $TABLES
do
	echo $table $table $table 
	for site in $SITES 
	do
		curl -o $table-$(echo $site | sed -e 's/https\?:\/\///').xml -u $LOGIN $site/special/O211_records.asp?Table=$table
	done
done

