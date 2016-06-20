// =========================================================================================
// Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =========================================================================================

(function() {
window['init_cm_checklist'] = function($, url, options) {
    var cache = {}, source_fn = create_caching_source_fn($, url, cache, 'label'),
    parent_cmid_input = options.parent_cmid_input || null, cm_checklist_counter=9999,
    cm_checklist_template = $('#cm-checklist-template').html(), cm_checklist_target=$('#cm-checklist-target'),
    parent_community_adding_src_fn = !parent_cmid_input ? source_fn : (function(request, response, override_url) {
        request.parent = parent_cmid_input.val();
        return source_fn(request, response, override_url);
    }),
    look_for_value = function(invalue, response, dont_source) {
        var inputvalue = string_ci_ai(invalue);
        var content = cache.content;
        if (cache.content) {
            var values = $.grep(cache.content, function(value) {
                        return string_ci_ai(value[options.match_prop]) === inputvalue;
                    });
            if (values.length === 1) {
                response(values[0]);
                return;
            }
        }
        if (dont_source || string_ci_ai(cache.term || "") === inputvalue) {
            response();
            return;
        }

        source_fn({term: inputvalue}, function(data) {
                    look_for_value(invalue, response, true);
                });
    },
    add_new_html = function(chkid, display) {
        to_add = $(cm_checklist_template.replace(/\[COUNT\]/g, cm_checklist_counter++).
                replace(/\[ID\]/g, chkid).replace(/\[LABEL\]/g, $('<div>').text(display).html()));
        if (cm_checklist_target.is(':hidden')) {
            cm_checklist_target.removeClass('hidden').append(to_add);
        }else{
            cm_checklist_target.append(to_add);
        }
        return false;
        
    };
    if (options.parent_cmid_input){
        parent_cmid_input = $(options.parent_cmid_input);
    }

    options.source = parent_community_adding_src_fn;
    options.look_for_fn = look_for_value;
    options.add_new_html = add_new_html;
    
    init_autocomplete_checklist($, options);

};
window['init_community_edit'] = function($) {
    var alt_name_counter = 9999,
        alt_name_template = null, alt_name_target = null,
    add_alternate_name = function(evt) {
        var to_add = null;
        evt.preventDefault();
        if (!alt_name_template) {
            alt_name_template = $('#alt-name-template').html();
            alt_name_target = $('#alt-name-target');
        }
        
        to_add = $(alt_name_template.replace(/\[COUNT\]/g, alt_name_counter++));
        if (alt_name_target.is(':hidden')) {
            alt_name_target.removeClass('hidden').append(to_add);
        }else{
            alt_name_target.append(to_add);
        }
        return false;
    };
    $('#add-alternate-name').click(add_alternate_name);
};

})();
