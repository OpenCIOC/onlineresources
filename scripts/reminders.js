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

window['CIOC'] = {};
(function(document, window) {
 window['do_drop_down_navigation'] = function() {
	var target = document.getElementById('ActionList');
	var options = target.options;
	for (var i = 0; i < options.length; i++) {
		if (options[i].selected) {
			var href = options[i].getAttribute('href');
			if (href) {
				if (typeof(options[i].attributes['newwindow']) != "undefined" ) {
					window.open(href);
				} else {
					window.location.href = href;
				}
			}
			return;
		}
	}
};
jQuery(function($) {
	$('[data-toggle=dialog]').each(function() {
		var self = $(this);
		var dialog = $(self.data('target'));
		var args = {
			autoOpen: false,
			title: dialog.data('title'),
			modal: dialog.data('modal')
		}
		dialog.dialog(args);
		self.click(function() {
			if (dialog.dialog('isOpen')) {
				dialog.dialog('close');
			} else {
				dialog.dialog('open');
			}
		});
	});
});
})(document, window);
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

function CheckAll(name, form) {
	if (!name) {
		name = "IDList";
	}
	var ml = form;
	if (!form) {
		ml = document.RecordList;
	}
	var len = ml.elements.length;
	for (var i = 0; i < len; i++) {
		var e = ml.elements[i];
		if (e.name === name) {
			e.checked = true;
		}
	}
}

function ClearAll(name, form) {
	if (!name) {
		name = "IDList";
	}
	var ml = form;
	if (!form) {
		ml = document.RecordList;
	}
	var len = ml.elements.length;
	for (var i = 0; i < len; i++) {
		var e = ml.elements[i];
		if (e.name === name) {
			e.checked = false;
		}
	}
}
function add_class(el, classname) {
	if (!el) {
		return;
	}
	var myRE = new RegExp("\\b" + classname + "\\b");
	if ( !myRE.test(el.className) ) {
		if (el.className) {
			classname = ' ' + classname;
		}
		el.className += classname;
	}
}

function remove_class(el, classname) {
	if (!el) {
		return;
	}
	var classnames = el.className.split(' ');
	var newclasses = [];
	for (var i = 0; i < classnames.length; i++) {
		var cn = classnames[i];
		if (cn !== classname) {
			newclasses.push(cn);
		}
	}
	el.className = newclasses.join(' ');
}

function hide(el) {
	add_class(el, 'NotVisible');
}

function show(el) {
	remove_class(el, 'NotVisible');
}

function openWin(pageToOpen,windowName)  {
	var popWin = window.open(pageToOpen,windowName,"toolbar=no,width=490,height=485,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

function openWinL(pageToOpen,windowName)  {
	var popWin = window.open(pageToOpen,windowName,"toolbar=no,width=650,height=520,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

function openWinXL(pageToOpen,windowName)  {
	var popWin = window.open(pageToOpen,windowName,"toolbar=no,width=755,height=550,location=no,scrollBars=yes,resizable=no,titlebar=yes");
	popWin.focus();
}

jQuery(function($) {
	var popfns = {
		sm: openWin,
		lg: openWinL,
		xl: openWinXL
	};
	$(document).on('click', 'a.poplink', function() {
		var args = $(this).data('popargs'), link = this.href,
			fn = (popfns[args.size || 'sm'] || openWin);
		
		fn(link, args.name || 'popwin');

		return false;
	});
});

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
var $ = jQuery;

var options = {};

var check_list_link = function(count) {
	if (count !== null && typeof count !== 'undefined') {
		$("#myListCount").text(count);
	} else {
		count = $('#myListCount').text();
		if (count) {
			count = parseInt(count, 10);
		}
	}
	if (count) {
		options.myListLink.show();
	} else {
		options.myListLink.hide();
	}
}
var mark_added = function(ids) {
	$.each(ids, function(index, item) {
		$("#added_to_list_" + item).show();
		$("#add_to_list_" + item).hide();
	});
}

var item_added_to_list = function(id){
	return function(result) {
		if (result.fail) {
			alert(result.errinfo);
			return;
		}

		if (result.ids) {
			check_list_link($.grep(result.ids, grep_fns[options.domain]).length);
		} else if (result.count) {
			check_list_link(result.count);
		} else {
			check_list_link(0);
		}

		mark_added([id]);
	};
}

var add_to_list_clicked = function(evt) {
	var target = evt.currentTarget;
	var id = $(target).data('id');

	$.ajax({
			success: item_added_to_list(id),
			dataType: 'json', 
			error: function() {alert("Error");},
			data: {id:id},
			type: 'POST',
			url: options.current_list_url
		});
}

var item_removed_from_list = function(id){
	return function(result) {
		if (result.fail) {
			alert(result.errinfo);
			return;
		}

		var table_results = true;
		if (id) {
			var el = $("#results_table #remove_from_list_" + id);
			if (!el.length) {
				table_results = false;
				el = $("#results_container #remove_from_list_" + id);
				el.parents('.dlist-result').remove();
			} else {
				el.parent().parent().remove();
			}
		}

		var hide = false;
		if (table_results) {
			hide = $('#results_table tr').length === 1;
		} else {
			hide = $('#results_container .dlist-result').length === 0;
		}

		if (hide || !id) {
			$("#records_ui").hide();
			$("#no_records_message").show();
		}
	};
}

var remove_from_list_clicked = function(evt) {
	var target = evt.currentTarget;
	var id = $(target).data('id');

	$.ajax({
			success: item_removed_from_list(id),
			dataType: 'json', 
			error: function() {alert("Error");},
			data: {ID:id, RemoveItem: options.domain},
			type: 'POST',
			url: options.current_list_url
		});
}

var remove_all_from_list_clicked = function(evt) {
	$.ajax({
			success: item_removed_from_list(),
			dataType: 'json', 
			error: function() {alert("Error");},
			data: {ID:'all', RemoveItem: options.domain},
			type: 'POST',
			url: options.current_list_url
		});
}

var grep_fns = {
CIC: function(el) { return /^[A-Za-z]{3}[0-9]{4,5}$/.test(el); },
VOL: function(el) { return /^[1-9][0-9]*$/.test(el); }
};

var init_ct_list_ui = function(result) {
		if (result.fail) {
			init_base_list_ui();
			return;
		}
		if ( !result.inrequest) {
			init_base_list_ui();
			return;
		}
		var ids = $.grep(result.ids, grep_fns[options.domain]);
		mark_added(ids);

		// XXX show link for clienttracker list
		check_list_link(ids.length);

		var previous_ids = result.previous_ids;
		if (previous_ids) {
			$.each(previous_ids, function(index, item) {
					$("#ct_added_to_previous_request_" + item).show();
				});
		}

		$('.ListUI img').prop('src', function(index, src) { 
				return src.replace('list', 'referral');
				} );

		$("#list_header_text").hide();
		$("#ct_header_text").show();

		options.current_list_url = options.ct_update_url;

		finalize_init();
}

var init_base_list_ui = function() {

	var run_setup = function(){
		if(!options.list_view_mode) {
			mark_added(options.already_added || []);
		}
		if (options.list_view_mode && options.list_view_mode === 'ct') {
			options.current_list_url = options.ct_update_url;
		} else {
			options.current_list_url = options.list_update_url;
		}
		check_list_link((options.already_added || []).length);

		finalize_init();
	}

	if (!options.list_view_mode && !options.has_session) {
		$.ajax({
			dataType: 'json', 
			error: null,
			url: options.list_update_url,
			data: { SessionTest: 'on' },
			type: 'POST',
			success: function(result) {
				if (result.has_session) {
					run_setup();
				}
			}
			});
	} else {
		run_setup();
	}
}

var finalize_init = function() {
	$('.HideListUI').
		delegate(".add_to_list", "click", add_to_list_clicked).
		delegate(".remove_from_list", "click", remove_from_list_clicked).
		removeClass('HideListUI');

	$("#remove_all_from_list").click(remove_all_from_list_clicked);
	

	if($.browser.msie && $.browser.msie < "8.0") {
		$(".ListUI").removeClass("FixIE");
	}
}

var init_list_adder = function(opt)
{
	options = opt;
	options.myListLink = $('#myListLink').parent(':hidden').add('#myListLink')
	if (opt.in_request) {
		$.ajax({
			success: init_ct_list_ui,
			dataType: 'json', 
			error: null,
			type: 'POST',
			url: opt.in_request
			});
		return;
	}

	init_base_list_ui();
}
window['init_list_adder'] = init_list_adder;
})();
/*
    http://www.JSON.org/json2.js
    2010-03-20

    Public Domain.

    NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

    See http://www.JSON.org/js.html


    This code should be minified before deployment.
    See http://javascript.crockford.com/jsmin.html

    USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
    NOT CONTROL.


    This file creates a global JSON object containing two methods: stringify
    and parse.

        JSON.stringify(value, replacer, space)
            value       any JavaScript value, usually an object or array.

            replacer    an optional parameter that determines how object
                        values are stringified for objects. It can be a
                        function or an array of strings.

            space       an optional parameter that specifies the indentation
                        of nested structures. If it is omitted, the text will
                        be packed without extra whitespace. If it is a number,
                        it will specify the number of spaces to indent at each
                        level. If it is a string (such as '\t' or '&nbsp;'),
                        it contains the characters used to indent at each level.

            This method produces a JSON text from a JavaScript value.

            When an object value is found, if the object contains a toJSON
            method, its toJSON method will be called and the result will be
            stringified. A toJSON method does not serialize: it returns the
            value represented by the name/value pair that should be serialized,
            or undefined if nothing should be serialized. The toJSON method
            will be passed the key associated with the value, and this will be
            bound to the value

            For example, this would serialize Dates as ISO strings.

                Date.prototype.toJSON = function (key) {
                    function f(n) {
                        // Format integers to have at least two digits.
                        return n < 10 ? '0' + n : n;
                    }

                    return this.getUTCFullYear()   + '-' +
                         f(this.getUTCMonth() + 1) + '-' +
                         f(this.getUTCDate())      + 'T' +
                         f(this.getUTCHours())     + ':' +
                         f(this.getUTCMinutes())   + ':' +
                         f(this.getUTCSeconds())   + 'Z';
                };

            You can provide an optional replacer method. It will be passed the
            key and value of each member, with this bound to the containing
            object. The value that is returned from your method will be
            serialized. If your method returns undefined, then the member will
            be excluded from the serialization.

            If the replacer parameter is an array of strings, then it will be
            used to select the members to be serialized. It filters the results
            such that only members with keys listed in the replacer array are
            stringified.

            Values that do not have JSON representations, such as undefined or
            functions, will not be serialized. Such values in objects will be
            dropped; in arrays they will be replaced with null. You can use
            a replacer function to replace those with JSON values.
            JSON.stringify(undefined) returns undefined.

            The optional space parameter produces a stringification of the
            value that is filled with line breaks and indentation to make it
            easier to read.

            If the space parameter is a non-empty string, then that string will
            be used for indentation. If the space parameter is a number, then
            the indentation will be that many spaces.

            Example:

            text = JSON.stringify(['e', {pluribus: 'unum'}]);
            // text is '["e",{"pluribus":"unum"}]'


            text = JSON.stringify(['e', {pluribus: 'unum'}], null, '\t');
            // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

            text = JSON.stringify([new Date()], function (key, value) {
                return this[key] instanceof Date ?
                    'Date(' + this[key] + ')' : value;
            });
            // text is '["Date(---current time---)"]'


        JSON.parse(text, reviver)
            This method parses a JSON text to produce an object or array.
            It can throw a SyntaxError exception.

            The optional reviver parameter is a function that can filter and
            transform the results. It receives each of the keys and values,
            and its return value is used instead of the original value.
            If it returns what it received, then the structure is not modified.
            If it returns undefined then the member is deleted.

            Example:

            // Parse the text. Values that look like ISO date strings will
            // be converted to Date objects.

            myData = JSON.parse(text, function (key, value) {
                var a;
                if (typeof value === 'string') {
                    a =
/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
                    if (a) {
                        return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4],
                            +a[5], +a[6]));
                    }
                }
                return value;
            });

            myData = JSON.parse('["Date(09/09/2001)"]', function (key, value) {
                var d;
                if (typeof value === 'string' &&
                        value.slice(0, 5) === 'Date(' &&
                        value.slice(-1) === ')') {
                    d = new Date(value.slice(5, -1));
                    if (d) {
                        return d;
                    }
                }
                return value;
            });


    This is a reference implementation. You are free to copy, modify, or
    redistribute.
*/

/*jslint evil: true, strict: false */

/*members "", "\b", "\t", "\n", "\f", "\r", "\"", JSON, "\\", apply,
    call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
    getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
    lastIndex, length, parse, prototype, push, replace, slice, stringify,
    test, toJSON, toString, valueOf
*/


// Create a JSON object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

if (!this.JSON) {
    this.JSON = {};
}

(function () {

    function f(n) {
        // Format integers to have at least two digits.
        return n < 10 ? '0' + n : n;
    }

    if (typeof Date.prototype.toJSON !== 'function') {

        Date.prototype.toJSON = function (key) {

            return isFinite(this.valueOf()) ?
                   this.getUTCFullYear()   + '-' +
                 f(this.getUTCMonth() + 1) + '-' +
                 f(this.getUTCDate())      + 'T' +
                 f(this.getUTCHours())     + ':' +
                 f(this.getUTCMinutes())   + ':' +
                 f(this.getUTCSeconds())   + 'Z' : null;
        };

        String.prototype.toJSON =
        Number.prototype.toJSON =
        Boolean.prototype.toJSON = function (key) {
            return this.valueOf();
        };
    }

    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
        gap,
        indent,
        meta = {    // table of character substitutions
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        escapable.lastIndex = 0;
        return escapable.test(string) ?
            '"' + string.replace(escapable, function (a) {
                var c = meta[a];
                return typeof c === 'string' ? c :
                    '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
            }) + '"' :
            '"' + string + '"';
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i,          // The loop counter.
            k,          // The member key.
            v,          // The member value.
            length,
            mind = gap,
            partial,
            value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (value && typeof value === 'object' &&
                typeof value.toJSON === 'function') {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === 'function') {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case 'string':
            return quote(value);

        case 'number':

// JSON numbers must be finite. Encode non-finite numbers as null.

            return isFinite(value) ? String(value) : 'null';

        case 'boolean':
        case 'null':

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce 'null'. The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is 'object', we might be dealing with an object or an array or
// null.

        case 'object':

// Due to a specification blunder in ECMAScript, typeof null is 'object',
// so watch out for that case.

            if (!value) {
                return 'null';
            }

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === '[object Array]') {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || 'null';
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0 ? '[]' :
                    gap ? '[\n' + gap +
                            partial.join(',\n' + gap) + '\n' +
                                mind + ']' :
                          '[' + partial.join(',') + ']';
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === 'object') {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    k = rep[i];
                    if (typeof k === 'string') {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (gap ? ': ' : ':') + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0 ? '{}' :
                gap ? '{\n' + gap + partial.join(',\n' + gap) + '\n' +
                        mind + '}' : '{' + partial.join(',') + '}';
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = '';
            indent = '';

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === 'number') {
                for (i = 0; i < space; i += 1) {
                    indent += ' ';
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === 'string') {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== 'function' &&
                    (typeof replacer !== 'object' ||
                     typeof replacer.length !== 'number')) {
                throw new Error('JSON.stringify');
            }

// Make a fake root object containing our value under the key of ''.
// Return the result of stringifying the value.

            return str('', {'': value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k, v, value = holder[key];
                if (value && typeof value === 'object') {
                    for (k in value) {
                        if (Object.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            cx.lastIndex = 0;
            if (cx.test(text)) {
                text = text.replace(cx, function (a) {
                    return '\\u' +
                        ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with '()' and 'new'
// because they can cause invocation, and '=' because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with '@' (a non-JSON character). Second, we
// replace all simple value tokens with ']' characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or ']' or
// ',' or ':' or '{' or '}'. If that is so, then the text is safe for eval.

            if (/^[\],:{}\s]*$/.
test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@').
replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The '{' operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval('(' + text + ')');

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return typeof reviver === 'function' ?
                    walk({'': j}, '') : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError('JSON.parse');
        };
    }
}());
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
window['get_form_values'] = function(selector) {
	var values = {};
	jQuery(selector).find('input,select,textarea').each(function (index) {
		if ( !this.name ) {
			return;
		}
		if (! values[this.name]) {
			values[this.name] = [];
		}
		if ( this.nodeName.toLowerCase() === 'select') {
			var valarray = values[this.name];
			$(this).find('option').each(function(index) {
					if(this.selected) {
						valarray.push(this.value);
					}
				});
			return;
		}
		if ( this.nodeName.toLowerCase() === 'input' && (this.type === 'checkbox' || 
				this.type === 'radio') && !this.checked ) {
			return;
		}
		values[this.name].push(this.value || '');
	});
	return values;
};

window['restore_form_values'] = function(selector, form_values) {
	var $ = jQuery;
	$(selector).find('input,select,textarea').each(function (index) {
		if ( !this.name ) {
			return;
		}
		var val = form_values[this.name];
		if ( typeof(val) == 'undefined' || val === null) {
			return;
		}
		
		var length = val.length;
		if ( this.nodeName.toLowerCase() === 'input' && ( this.type === 'checkbox' ||
				this.type === 'radio') )  {
			if (val.length > 1) {
				this.checked = $.inArray(this.value, val) >= 0;
			} else if (val.length === 0) {
				this.checked = false;
			} else {
				this.checked = this.value === val[0];
			}
			return;
		}

		if (this.nodeName.toLowerCase() === 'select') {
			$(this).find('option').each(function (index) {
				if (val.length > 1) {
					this.selected = $.inArray(this.value, val) >= 0;
				} else if (val.length === 0) {
					this.selected = false;
				} else {
					this.selected = this.value === val[0];
				}
			});
			return;
		}

		if ( val.length ) {
			this.value = val[0];
		} else {
			this.value = "";
		}
	});
};

window['init_cached_state'] = function(formselector) {
	var $ = jQuery;
	formselector = formselector || "#EntryForm";
	onbeforeunload_fns = [];
	onbeforerestorevalues_fns = [];

	$(window).on('beforeunload', function() {
		var values = get_form_values(formselector);
		var cache= {form_values :values};

		$.each(onbeforeunload_fns, function(index, item) {
			item(cache);
		});

		var cache_dom = document.getElementById('cache_form_values');
		cache_dom.value = JSON.stringify(cache);

	});

	var cache_register_onbeforeunload = function(fn) {
		onbeforeunload_fns.push(fn);
	};

	window['cache_register_onbeforeunload'] = cache_register_onbeforeunload;

	var cache_register_onbeforerestorevalues = function(fn) {
		onbeforerestorevalues_fns.push(fn);
	};

	window['cache_register_onbeforerestorevalues'] = cache_register_onbeforerestorevalues;

	var restore_cached_state = function() {
		var cache_dom = document.getElementById('cache_form_values');
		if (!cache_dom || !cache_dom.value) {
			return;
		}

		var cache = JSON.parse(cache_dom.value);

		$.each(onbeforerestorevalues_fns, function(index,item) {
			item(cache);
		});

		restore_form_values(formselector, cache.form_values);

	};
	window['restore_cached_state'] = restore_cached_state;
};

})();
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
	var $ = jQuery,
		dateformat = {
			'en-CA': 'd M yy',
			'de': 'dd.mm.yy',
			'fr': 'd M yy',
			'it': 'd M yy',
			'nl': 'd M yy',
			'no': 'd M yy',
			'pt': 'd-mm-yy',
			'sv': 'd M yy',
			'hu': 'M d. yy',
			'ro': 'd M yy',
			'hr': 'd M yy',
			'sl': 'd M yy',
			'bg': 'd MM yy',
			'ru': 'd M yy',
			'tr': 'd M yy',
			'lv': 'd M yy',
			'lt': 'd M yy',
			'ko': 'yy/mm/dd',
			'zh-CN': 'yy/mm/dd',
			'th': 'd M yy'
		},
		loaded = {'en-CA': true, '': true},
		loading = {},
		culture_map = {'fr-CA': 'fr', 'es-MX': 'es'},
		fix_culture = function(culture) {
			return culture_map[culture] || culture;
		},
		load_datepicker = function() {
				var self = $(this), culture = self.data('culture'),
					format = dateformat[culture] || $.datepicker.regional[culture].dateFormat,
					args = {};
				
				if (self.hasClass('NoYear')) {
					format = format.replace(/[\- .\/]*yy[\/]?/, '');
					args = {
						beforeShow: function (input, inst) {
							inst.dpDiv.addClass('NoYearDatePicker');
						},
						onClose: function(dateText, inst){
							inst.dpDiv.removeClass('NoYearDatePicker');
						},
						changeYear: false
					};
				}
				args['dateFormat'] = format;
				self.datepicker($.extend({},$.datepicker.regional[culture],
						args)).prop('autocomplete', 'off');
		},
		load_culture = function(culture) {
			$.getScript("//ajax.googleapis.com/ajax/libs/jqueryui/" + $.ui.version + "/i18n/jquery.ui.datepicker-" + culture + '.min.js',
				function() {
					loaded[culture] = true;
					$.each(loading[culture], function() {
						load_datepicker.call(this);
					});
					delete loading[culture];
				});
		};

	
	$.datepicker.regional['en-CA'] = $.extend({},$.datepicker.regional['']);
	


	$.fn.extend({
		autodatepicker: function() {
			return this.each(function() {
				var self = $(this), culture = fix_culture(self.parents('[lang]').first().prop('lang') || 'en-CA');
				self.data('culture', culture);
				if (loaded[culture]) {
					load_datepicker.call(this);
					return;
				}
				
				var arr = loading[culture];
				if (!arr) {
					arr = loading[culture] = [];
					load_culture(culture);
				}

				arr.push(this);
			});
		}

	});

	jQuery(function() {
		$("input.DatePicker").autodatepicker();
	});
})();


/**
 * jQuery Validation Plugin 1.9.0
 *
 * http://bassistance.de/jquery-plugins/jquery-plugin-validation/
 * http://docs.jquery.com/Plugins/Validation
 *
 * Copyright (c) 2006 - 2011 Jörn Zaefferer
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */

(function($) {

$.extend($.fn, {
	// http://docs.jquery.com/Plugins/Validation/validate
	validate: function( options ) {

		// if nothing is selected, return nothing; can't chain anyway
		if (!this.length) {
			options && options.debug && window.console && console.warn( "nothing selected, can't validate, returning nothing" );
			return;
		}

		// check if a validator for this form was already created
		var validator = $.data(this[0], 'validator');
		if ( validator ) {
			return validator;
		}

		// Add novalidate tag if HTML5.
		this.attr('novalidate', 'novalidate');

		validator = new $.validator( options, this[0] );
		$.data(this[0], 'validator', validator);

		if ( validator.settings.onsubmit ) {

			var inputsAndButtons = this.find("input, button");

			// allow suppresing validation by adding a cancel class to the submit button
			inputsAndButtons.filter(".cancel").click(function () {
				validator.cancelSubmit = true;
			});

			// when a submitHandler is used, capture the submitting button
			if (validator.settings.submitHandler) {
				inputsAndButtons.filter(":submit").click(function () {
					validator.submitButton = this;
				});
			}

			// validate the form on submit
			this.submit( function( event ) {
				if ( validator.settings.debug )
					// prevent form submit to be able to see console output
					event.preventDefault();

				function handle() {
					if ( validator.settings.submitHandler ) {
						if (validator.submitButton) {
							// insert a hidden input as a replacement for the missing submit button
							var hidden = $("<input type='hidden'/>").attr("name", validator.submitButton.name).val(validator.submitButton.value).appendTo(validator.currentForm);
						}
						validator.settings.submitHandler.call( validator, validator.currentForm );
						if (validator.submitButton) {
							// and clean up afterwards; thanks to no-block-scope, hidden can be referenced
							hidden.remove();
						}
						return false;
					}
					return true;
				}

				// prevent submit for invalid forms or custom submit handlers
				if ( validator.cancelSubmit ) {
					validator.cancelSubmit = false;
					return handle();
				}
				if ( validator.form() ) {
					if ( validator.pendingRequest ) {
						validator.formSubmitted = true;
						return false;
					}
					return handle();
				} else {
					validator.focusInvalid();
					return false;
				}
			});
		}

		return validator;
	},
	// http://docs.jquery.com/Plugins/Validation/valid
	valid: function() {
        if ( $(this[0]).is('form')) {
            return this.validate().form();
        } else {
            var valid = true;
            var validator = $(this[0].form).validate();
            this.each(function() {
				valid &= validator.element(this);
            });
            return valid;
        }
    },
	// attributes: space seperated list of attributes to retrieve and remove
	removeAttrs: function(attributes) {
		var result = {},
			$element = this;
		$.each(attributes.split(/\s/), function(index, value) {
			result[value] = $element.attr(value);
			$element.removeAttr(value);
		});
		return result;
	},
	// http://docs.jquery.com/Plugins/Validation/rules
	rules: function(command, argument) {
		var element = this[0];

		if (command) {
			var settings = $.data(element.form, 'validator').settings;
			var staticRules = settings.rules;
			var existingRules = $.validator.staticRules(element);
			switch(command) {
			case "add":
				$.extend(existingRules, $.validator.normalizeRule(argument));
				staticRules[element.name] = existingRules;
				if (argument.messages)
					settings.messages[element.name] = $.extend( settings.messages[element.name], argument.messages );
				break;
			case "remove":
				if (!argument) {
					delete staticRules[element.name];
					return existingRules;
				}
				var filtered = {};
				$.each(argument.split(/\s/), function(index, method) {
					filtered[method] = existingRules[method];
					delete existingRules[method];
				});
				return filtered;
			}
		}

		var data = $.validator.normalizeRules(
		$.extend(
			{},
			$.validator.metadataRules(element),
			$.validator.classRules(element),
			$.validator.attributeRules(element),
			$.validator.staticRules(element)
		), element);

		// make sure required is at front
		if (data.required) {
			var param = data.required;
			delete data.required;
			data = $.extend({required: param}, data);
		}

		return data;
	}
});

// Custom selectors
$.extend($.expr[":"], {
	// http://docs.jquery.com/Plugins/Validation/blank
	blank: function(a) {return !$.trim("" + a.value);},
	// http://docs.jquery.com/Plugins/Validation/filled
	filled: function(a) {return !!$.trim("" + a.value);},
	// http://docs.jquery.com/Plugins/Validation/unchecked
	unchecked: function(a) {return !a.checked;}
});

// constructor for validator
$.validator = function( options, form ) {
	this.settings = $.extend( true, {}, $.validator.defaults, options );
	this.currentForm = form;
	this.init();
};

$.validator.format = function(source, params) {
	if ( arguments.length == 1 )
		return function() {
			var args = $.makeArray(arguments);
			args.unshift(source);
			return $.validator.format.apply( this, args );
		};
	if ( arguments.length > 2 && params.constructor != Array  ) {
		params = $.makeArray(arguments).slice(1);
	}
	if ( params.constructor != Array ) {
		params = [ params ];
	}
	$.each(params, function(i, n) {
		source = source.replace(new RegExp("\\{" + i + "\\}", "g"), n);
	});
	return source;
};

$.extend($.validator, {

	defaults: {
		messages: {},
		groups: {},
		rules: {},
		errorClass: "error",
		validClass: "valid",
		errorElement: "label",
		focusInvalid: true,
		errorContainer: $( [] ),
		errorLabelContainer: $( [] ),
		onsubmit: true,
		ignore: ":hidden",
		ignoreTitle: false,
		onfocusin: function(element, event) {
			this.lastActive = element;

			// hide error label and remove error class on focus if enabled
			if ( this.settings.focusCleanup && !this.blockFocusCleanup ) {
				this.settings.unhighlight && this.settings.unhighlight.call( this, element, this.settings.errorClass, this.settings.validClass );
				this.addWrapper(this.errorsFor(element)).hide();
			}
		},
		onfocusout: function(element, event) {
			if ( !this.checkable(element) && (element.name in this.submitted || !this.optional(element)) ) {
				this.element(element);
			}
		},
		onkeyup: function(element, event) {
			if ( element.name in this.submitted || element == this.lastElement ) {
				this.element(element);
			}
		},
		onclick: function(element, event) {
			// click on selects, radiobuttons and checkboxes
			if ( element.name in this.submitted )
				this.element(element);
			// or option elements, check parent select in that case
			else if (element.parentNode.name in this.submitted)
				this.element(element.parentNode);
		},
		highlight: function(element, errorClass, validClass) {
			if (element.type === 'radio') {
				this.findByName(element.name).addClass(errorClass).removeClass(validClass);
			} else {
				$(element).addClass(errorClass).removeClass(validClass);
			}
		},
		unhighlight: function(element, errorClass, validClass) {
			if (element.type === 'radio') {
				this.findByName(element.name).removeClass(errorClass).addClass(validClass);
			} else {
				$(element).removeClass(errorClass).addClass(validClass);
			}
		}
	},

	// http://docs.jquery.com/Plugins/Validation/Validator/setDefaults
	setDefaults: function(settings) {
		$.extend( $.validator.defaults, settings );
	},

	messages: {
		required: "This field is required.",
		remote: "Please fix this field.",
		email: "Please enter a valid email address.",
		url: "Please enter a valid URL.",
		date: "Please enter a valid date.",
		dateISO: "Please enter a valid date (ISO).",
		number: "Please enter a valid number.",
		digits: "Please enter only digits.",
		creditcard: "Please enter a valid credit card number.",
		equalTo: "Please enter the same value again.",
		accept: "Please enter a value with a valid extension.",
		maxlength: $.validator.format("Please enter no more than {0} characters."),
		minlength: $.validator.format("Please enter at least {0} characters."),
		rangelength: $.validator.format("Please enter a value between {0} and {1} characters long."),
		range: $.validator.format("Please enter a value between {0} and {1}."),
		max: $.validator.format("Please enter a value less than or equal to {0}."),
		min: $.validator.format("Please enter a value greater than or equal to {0}.")
	},

	autoCreateRanges: false,

	prototype: {

		init: function() {
			this.labelContainer = $(this.settings.errorLabelContainer);
			this.errorContext = this.labelContainer.length && this.labelContainer || $(this.currentForm);
			this.containers = $(this.settings.errorContainer).add( this.settings.errorLabelContainer );
			this.submitted = {};
			this.valueCache = {};
			this.pendingRequest = 0;
			this.pending = {};
			this.invalid = {};
			this.reset();

			var groups = (this.groups = {});
			$.each(this.settings.groups, function(key, value) {
				$.each(value.split(/\s/), function(index, name) {
					groups[name] = key;
				});
			});
			var rules = this.settings.rules;
			$.each(rules, function(key, value) {
				rules[key] = $.validator.normalizeRule(value);
			});

			function delegate(event) {
				var validator = $.data(this[0].form, "validator"),
					eventType = "on" + event.type.replace(/^validate/, "");
				validator.settings[eventType] && validator.settings[eventType].call(validator, this[0], event);
			}
			$(this.currentForm)
			       .validateDelegate("[type='text'], [type='password'], [type='file'], select, textarea, " +
						"[type='number'], [type='search'] ,[type='tel'], [type='url'], " +
						"[type='email'], [type='datetime'], [type='date'], [type='month'], " +
						"[type='week'], [type='time'], [type='datetime-local'], " +
						"[type='range'], [type='color'] ",
						"focusin focusout keyup", delegate)
				.validateDelegate("[type='radio'], [type='checkbox'], select, option", "click", delegate);

			if (this.settings.invalidHandler)
				$(this.currentForm).bind("invalid-form.validate", this.settings.invalidHandler);
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/form
		form: function() {
			this.checkForm();
			$.extend(this.submitted, this.errorMap);
			this.invalid = $.extend({}, this.errorMap);
			if (!this.valid())
				$(this.currentForm).triggerHandler("invalid-form", [this]);
			this.showErrors();
			return this.valid();
		},

		checkForm: function() {
			this.prepareForm();
			for ( var i = 0, elements = (this.currentElements = this.elements()); elements[i]; i++ ) {
				this.check( elements[i] );
			}
			return this.valid();
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/element
		element: function( element ) {
			element = this.validationTargetFor( this.clean( element ) );
			this.lastElement = element;
			this.prepareElement( element );
			this.currentElements = $(element);
			var result = this.check( element );
			if ( result ) {
				delete this.invalid[element.name];
			} else {
				this.invalid[element.name] = true;
			}
			if ( !this.numberOfInvalids() ) {
				// Hide error containers on last error
				this.toHide = this.toHide.add( this.containers );
			}
			this.showErrors();
			return result;
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/showErrors
		showErrors: function(errors) {
			if(errors) {
				// add items to error list and map
				$.extend( this.errorMap, errors );
				this.errorList = [];
				for ( var name in errors ) {
					this.errorList.push({
						message: errors[name],
						element: this.findByName(name)[0]
					});
				}
				// remove items from success list
				this.successList = $.grep( this.successList, function(element) {
					return !(element.name in errors);
				});
			}
			this.settings.showErrors
				? this.settings.showErrors.call( this, this.errorMap, this.errorList )
				: this.defaultShowErrors();
		},

		// http://docs.jquery.com/Plugins/Validation/Validator/resetForm
		resetForm: function() {
			if ( $.fn.resetForm )
				$( this.currentForm ).resetForm();
			this.submitted = {};
			this.lastElement = null;
			this.prepareForm();
			this.hideErrors();
			this.elements().removeClass( this.settings.errorClass );
		},

		numberOfInvalids: function() {
			return this.objectLength(this.invalid);
		},

		objectLength: function( obj ) {
			var count = 0;
			for ( var i in obj )
				count++;
			return count;
		},

		hideErrors: function() {
			this.addWrapper( this.toHide ).hide();
		},

		valid: function() {
			return this.size() == 0;
		},

		size: function() {
			return this.errorList.length;
		},

		focusInvalid: function() {
			if( this.settings.focusInvalid ) {
				try {
					$(this.findLastActive() || this.errorList.length && this.errorList[0].element || [])
					.filter(":visible")
					.focus()
					// manually trigger focusin event; without it, focusin handler isn't called, findLastActive won't have anything to find
					.trigger("focusin");
				} catch(e) {
					// ignore IE throwing errors when focusing hidden elements
				}
			}
		},

		findLastActive: function() {
			var lastActive = this.lastActive;
			return lastActive && $.grep(this.errorList, function(n) {
				return n.element.name == lastActive.name;
			}).length == 1 && lastActive;
		},

		elements: function() {
			var validator = this,
				rulesCache = {};

			// select all valid inputs inside the form (no submit or reset buttons)
			return $(this.currentForm)
			.find("input, select, textarea")
			.not(":submit, :reset, :image, [disabled]")
			.not( this.settings.ignore )
			.filter(function() {
				!this.name && validator.settings.debug && window.console && console.error( "%o has no name assigned", this);

				// select only the first element for each name, and only those with rules specified
				if ( this.name in rulesCache || !validator.objectLength($(this).rules()) )
					return false;

				rulesCache[this.name] = true;
				return true;
			});
		},

		clean: function( selector ) {
			return $( selector )[0];
		},

		errors: function() {
			return $( this.settings.errorElement + "." + this.settings.errorClass, this.errorContext );
		},

		reset: function() {
			this.successList = [];
			this.errorList = [];
			this.errorMap = {};
			this.toShow = $([]);
			this.toHide = $([]);
			this.currentElements = $([]);
		},

		prepareForm: function() {
			this.reset();
			this.toHide = this.errors().add( this.containers );
		},

		prepareElement: function( element ) {
			this.reset();
			this.toHide = this.errorsFor(element);
		},

		check: function( element ) {
			element = this.validationTargetFor( this.clean( element ) );

			var rules = $(element).rules();
			var dependencyMismatch = false;
			for (var method in rules ) {
				var rule = { method: method, parameters: rules[method] };
				try {
					var result = $.validator.methods[method].call( this, element.value.replace(/\r/g, ""), element, rule.parameters );

					// if a method indicates that the field is optional and therefore valid,
					// don't mark it as valid when there are no other rules
					if ( result == "dependency-mismatch" ) {
						dependencyMismatch = true;
						continue;
					}
					dependencyMismatch = false;

					if ( result == "pending" ) {
						this.toHide = this.toHide.not( this.errorsFor(element) );
						return;
					}

					if( !result ) {
						this.formatAndAdd( element, rule );
						return false;
					}
				} catch(e) {
					this.settings.debug && window.console && console.log("exception occured when checking element " + element.id
						 + ", check the '" + rule.method + "' method", e);
					throw e;
				}
			}
			if (dependencyMismatch)
				return;
			if ( this.objectLength(rules) )
				this.successList.push(element);
			return true;
		},

		// return the custom message for the given element and validation method
		// specified in the element's "messages" metadata
		customMetaMessage: function(element, method) {
			if (!$.metadata)
				return;

			var meta = this.settings.meta
				? $(element).metadata()[this.settings.meta]
				: $(element).metadata();

			return meta && meta.messages && meta.messages[method];
		},

		// return the custom message for the given element name and validation method
		customMessage: function( name, method ) {
			var m = this.settings.messages[name];
			return m && (m.constructor == String
				? m
				: m[method]);
		},

		// return the first defined argument, allowing empty strings
		findDefined: function() {
			for(var i = 0; i < arguments.length; i++) {
				if (arguments[i] !== undefined)
					return arguments[i];
			}
			return undefined;
		},

		defaultMessage: function( element, method) {
			return this.findDefined(
				this.customMessage( element.name, method ),
				this.customMetaMessage( element, method ),
				// title is never undefined, so handle empty string as undefined
				!this.settings.ignoreTitle && element.title || undefined,
				$.validator.messages[method],
				"<strong>Warning: No message defined for " + element.name + "</strong>"
			);
		},

		formatAndAdd: function( element, rule ) {
			var message = this.defaultMessage( element, rule.method ),
				theregex = /\$?\{(\d+)\}/g;
			if ( typeof message == "function" ) {
				message = message.call(this, rule.parameters, element);
			} else if (theregex.test(message)) {
				message = jQuery.format(message.replace(theregex, '{$1}'), rule.parameters);
			}
			this.errorList.push({
				message: message,
				element: element
			});

			this.errorMap[element.name] = message;
			this.submitted[element.name] = message;
		},

		addWrapper: function(toToggle) {
			if ( this.settings.wrapper )
				toToggle = toToggle.add( toToggle.parent( this.settings.wrapper ) );
			return toToggle;
		},

		defaultShowErrors: function() {
			for ( var i = 0; this.errorList[i]; i++ ) {
				var error = this.errorList[i];
				this.settings.highlight && this.settings.highlight.call( this, error.element, this.settings.errorClass, this.settings.validClass );
				this.showLabel( error.element, error.message );
			}
			if( this.errorList.length ) {
				this.toShow = this.toShow.add( this.containers );
			}
			if (this.settings.success) {
				for ( var i = 0; this.successList[i]; i++ ) {
					this.showLabel( this.successList[i] );
				}
			}
			if (this.settings.unhighlight) {
				for ( var i = 0, elements = this.validElements(); elements[i]; i++ ) {
					this.settings.unhighlight.call( this, elements[i], this.settings.errorClass, this.settings.validClass );
				}
			}
			this.toHide = this.toHide.not( this.toShow );
			this.hideErrors();
			this.addWrapper( this.toShow ).show();
		},

		validElements: function() {
			return this.currentElements.not(this.invalidElements());
		},

		invalidElements: function() {
			return $(this.errorList).map(function() {
				return this.element;
			});
		},

		showLabel: function(element, message) {
			var label = this.errorsFor( element );
			if ( label.length ) {
				// refresh error/success class
				label.removeClass( this.settings.validClass ).addClass( this.settings.errorClass );

				// check if we have a generated label, replace the message then
				label.attr("generated") && label.html(message);
			} else {
				// create label
				label = $("<" + this.settings.errorElement + "/>")
					.attr({"for":  this.idOrName(element), generated: true})
					.addClass(this.settings.errorClass)
					.html(message || "");
				if ( this.settings.wrapper ) {
					// make sure the element is visible, even in IE
					// actually showing the wrapped element is handled elsewhere
					label = label.hide().show().wrap("<" + this.settings.wrapper + "/>").parent();
				}
				if ( !this.labelContainer.append(label).length )
					this.settings.errorPlacement
						? this.settings.errorPlacement(label, $(element) )
						: label.insertAfter(element);
			}
			if ( !message && this.settings.success ) {
				label.text("");
				typeof this.settings.success == "string"
					? label.addClass( this.settings.success )
					: this.settings.success( label );
			}
			this.toShow = this.toShow.add(label);
		},

		errorsFor: function(element) {
			var name = this.idOrName(element);
    		return this.errors().filter(function() {
				return $(this).attr('for') == name;
			});
		},

		idOrName: function(element) {
			return this.groups[element.name] || (this.checkable(element) ? element.name : element.id || element.name);
		},

		validationTargetFor: function(element) {
			// if radio/checkbox, validate first element in group instead
			if (this.checkable(element)) {
				element = this.findByName( element.name ).not(this.settings.ignore)[0];
			}
			return element;
		},

		checkable: function( element ) {
			return /radio|checkbox/i.test(element.type);
		},

		findByName: function( name ) {
			// select by name and filter by form for performance over form.find("[name=...]")
			var form = this.currentForm;
			return $(document.getElementsByName(name)).map(function(index, element) {
				return element.form == form && element.name == name && element  || null;
			});
		},

		getLength: function(value, element) {
			switch( element.nodeName.toLowerCase() ) {
			case 'select':
				return $("option:selected", element).length;
			case 'input':
				if( this.checkable( element) )
					return this.findByName(element.name).filter(':checked').length;
			}
			return value.length;
		},

		depend: function(param, element) {
			return this.dependTypes[typeof param]
				? this.dependTypes[typeof param](param, element)
				: true;
		},

		dependTypes: {
			"boolean": function(param, element) {
				return param;
			},
			"string": function(param, element) {
				return !!$(param, element.form).length;
			},
			"function": function(param, element) {
				return param(element);
			}
		},

		optional: function(element) {
			return !$.validator.methods.required.call(this, $.trim(element.value), element) && "dependency-mismatch";
		},

		startRequest: function(element) {
			if (!this.pending[element.name]) {
				this.pendingRequest++;
				this.pending[element.name] = true;
			}
		},

		stopRequest: function(element, valid) {
			this.pendingRequest--;
			// sometimes synchronization fails, make sure pendingRequest is never < 0
			if (this.pendingRequest < 0)
				this.pendingRequest = 0;
			delete this.pending[element.name];
			if ( valid && this.pendingRequest == 0 && this.formSubmitted && this.form() ) {
				$(this.currentForm).submit();
				this.formSubmitted = false;
			} else if (!valid && this.pendingRequest == 0 && this.formSubmitted) {
				$(this.currentForm).triggerHandler("invalid-form", [this]);
				this.formSubmitted = false;
			}
		},

		previousValue: function(element) {
			return $.data(element, "previousValue") || $.data(element, "previousValue", {
				old: null,
				valid: true,
				message: this.defaultMessage( element, "remote" )
			});
		}

	},

	classRuleSettings: {
		required: {required: true},
		email: {email: true},
		url: {url: true},
		date: {date: true},
		dateISO: {dateISO: true},
		dateDE: {dateDE: true},
		number: {number: true},
		numberDE: {numberDE: true},
		digits: {digits: true},
		creditcard: {creditcard: true}
	},

	addClassRules: function(className, rules) {
		className.constructor == String ?
			this.classRuleSettings[className] = rules :
			$.extend(this.classRuleSettings, className);
	},

	classRules: function(element) {
		var rules = {};
		var classes = $(element).attr('class');
		classes && $.each(classes.split(' '), function() {
			if (this in $.validator.classRuleSettings) {
				$.extend(rules, $.validator.classRuleSettings[this]);
			}
		});
		return rules;
	},

	attributeRules: function(element) {
		var rules = {};
		var $element = $(element);

		for (var method in $.validator.methods) {
			var value;
			// If .prop exists (jQuery >= 1.6), use it to get true/false for required
			if (method === 'required' && typeof $.fn.prop === 'function') {
				value = $element.prop(method);
			} else {
				value = $element.attr(method);
			}
			if (value) {
				rules[method] = value;
			} else if ($element[0].getAttribute("type") === method) {
				rules[method] = true;
			}
		}

		// maxlength may be returned as -1, 2147483647 (IE) and 524288 (safari) for text inputs
		if (rules.maxlength && /-1|2147483647|524288/.test(rules.maxlength)) {
			delete rules.maxlength;
		}

		return rules;
	},

	metadataRules: function(element) {
		if (!$.metadata) return {};

		var meta = $.data(element.form, 'validator').settings.meta;
		return meta ?
			$(element).metadata()[meta] :
			$(element).metadata();
	},

	staticRules: function(element) {
		var rules = {};
		var validator = $.data(element.form, 'validator');
		if (validator.settings.rules) {
			rules = $.validator.normalizeRule(validator.settings.rules[element.name]) || {};
		}
		return rules;
	},

	normalizeRules: function(rules, element) {
		// handle dependency check
		$.each(rules, function(prop, val) {
			// ignore rule when param is explicitly false, eg. required:false
			if (val === false) {
				delete rules[prop];
				return;
			}
			if (val.param || val.depends) {
				var keepRule = true;
				switch (typeof val.depends) {
					case "string":
						keepRule = !!$(val.depends, element.form).length;
						break;
					case "function":
						keepRule = val.depends.call(element, element);
						break;
				}
				if (keepRule) {
					rules[prop] = val.param !== undefined ? val.param : true;
				} else {
					delete rules[prop];
				}
			}
		});

		// evaluate parameters
		$.each(rules, function(rule, parameter) {
			rules[rule] = $.isFunction(parameter) ? parameter(element) : parameter;
		});

		// clean number parameters
		$.each(['minlength', 'maxlength', 'min', 'max'], function() {
			if (rules[this]) {
				rules[this] = Number(rules[this]);
			}
		});
		$.each(['rangelength', 'range'], function() {
			if (rules[this]) {
				rules[this] = [Number(rules[this][0]), Number(rules[this][1])];
			}
		});

		if ($.validator.autoCreateRanges) {
			// auto-create ranges
			if (rules.min && rules.max) {
				rules.range = [rules.min, rules.max];
				delete rules.min;
				delete rules.max;
			}
			if (rules.minlength && rules.maxlength) {
				rules.rangelength = [rules.minlength, rules.maxlength];
				delete rules.minlength;
				delete rules.maxlength;
			}
		}

		// To support custom messages in metadata ignore rule methods titled "messages"
		if (rules.messages) {
			delete rules.messages;
		}

		return rules;
	},

	// Converts a simple string to a {string: true} rule, e.g., "required" to {required:true}
	normalizeRule: function(data) {
		if( typeof data == "string" ) {
			var transformed = {};
			$.each(data.split(/\s/), function() {
				transformed[this] = true;
			});
			data = transformed;
		}
		return data;
	},

	// http://docs.jquery.com/Plugins/Validation/Validator/addMethod
	addMethod: function(name, method, message) {
		$.validator.methods[name] = method;
		$.validator.messages[name] = message != undefined ? message : $.validator.messages[name];
		if (method.length < 3) {
			$.validator.addClassRules(name, $.validator.normalizeRule(name));
		}
	},

	methods: {

		// http://docs.jquery.com/Plugins/Validation/Methods/required
		required: function(value, element, param) {
			// check if dependency is met
			if ( !this.depend(param, element) )
				return "dependency-mismatch";
			switch( element.nodeName.toLowerCase() ) {
			case 'select':
				// could be an array for select-multiple or a string, both are fine this way
				var val = $(element).val();
				return val && val.length > 0;
			case 'input':
				if ( this.checkable(element) )
					return this.getLength(value, element) > 0;
			default:
				return $.trim(value).length > 0;
			}
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/remote
		remote: function(value, element, param) {
			if ( this.optional(element) )
				return "dependency-mismatch";

			var previous = this.previousValue(element);
			if (!this.settings.messages[element.name] )
				this.settings.messages[element.name] = {};
			previous.originalMessage = this.settings.messages[element.name].remote;
			this.settings.messages[element.name].remote = previous.message;

			param = typeof param == "string" && {url:param} || param;

			if ( this.pending[element.name] ) {
				return "pending";
			}
			if ( previous.old === value ) {
				return previous.valid;
			}

			previous.old = value;
			var validator = this;
			this.startRequest(element);
			var data = {};
			data[element.name] = value;
			$.ajax($.extend(true, {
				url: param,
				mode: "abort",
				port: "validate" + element.name,
				dataType: "json",
				data: data,
				success: function(response) {
					validator.settings.messages[element.name].remote = previous.originalMessage;
					var valid = response === true;
					if ( valid ) {
						var submitted = validator.formSubmitted;
						validator.prepareElement(element);
						validator.formSubmitted = submitted;
						validator.successList.push(element);
						validator.showErrors();
					} else {
						var errors = {};
						var message = response || validator.defaultMessage( element, "remote" );
						errors[element.name] = previous.message = $.isFunction(message) ? message(value) : message;
						validator.showErrors(errors);
					}
					previous.valid = valid;
					validator.stopRequest(element, valid);
				}
			}, param));
			return "pending";
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/minlength
		minlength: function(value, element, param) {
			return this.optional(element) || this.getLength($.trim(value), element) >= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/maxlength
		maxlength: function(value, element, param) {
			return this.optional(element) || this.getLength($.trim(value), element) <= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/rangelength
		rangelength: function(value, element, param) {
			var length = this.getLength($.trim(value), element);
			return this.optional(element) || ( length >= param[0] && length <= param[1] );
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/min
		min: function( value, element, param ) {
			return this.optional(element) || value >= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/max
		max: function( value, element, param ) {
			return this.optional(element) || value <= param;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/range
		range: function( value, element, param ) {
			return this.optional(element) || ( value >= param[0] && value <= param[1] );
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/email
		email: function(value, element) {
			// contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/
			return this.optional(element) || /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/url
		url: function(value, element) {
			// contributed by Scott Gonzalez: http://projects.scottsplayground.com/iri/
			return this.optional(element) || /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/date
		date: function(value, element) {
			return this.optional(element) || !/Invalid|NaN/.test(new Date(value));
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/dateISO
		dateISO: function(value, element) {
			return this.optional(element) || /^\d{4}[\/-]\d{1,2}[\/-]\d{1,2}$/.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/number
		number: function(value, element) {
			return this.optional(element) || /^-?(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$/.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/digits
		digits: function(value, element) {
			return this.optional(element) || /^\d+$/.test(value);
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/creditcard
		// based on http://en.wikipedia.org/wiki/Luhn
		creditcard: function(value, element) {
			if ( this.optional(element) )
				return "dependency-mismatch";
			// accept only spaces, digits and dashes
			if (/[^0-9 -]+/.test(value))
				return false;
			var nCheck = 0,
				nDigit = 0,
				bEven = false;

			value = value.replace(/\D/g, "");

			for (var n = value.length - 1; n >= 0; n--) {
				var cDigit = value.charAt(n);
				var nDigit = parseInt(cDigit, 10);
				if (bEven) {
					if ((nDigit *= 2) > 9)
						nDigit -= 9;
				}
				nCheck += nDigit;
				bEven = !bEven;
			}

			return (nCheck % 10) == 0;
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/accept
		accept: function(value, element, param) {
			param = typeof param == "string" ? param.replace(/,/g, '|') : "png|jpe?g|gif";
			return this.optional(element) || value.match(new RegExp(".(" + param + ")$", "i"));
		},

		// http://docs.jquery.com/Plugins/Validation/Methods/equalTo
		equalTo: function(value, element, param) {
			// bind to the blur event of the target in order to revalidate whenever the target field is updated
			// TODO find a way to bind the event just once, avoiding the unbind-rebind overhead
			var target = $(param).unbind(".validate-equalTo").bind("blur.validate-equalTo", function() {
				$(element).valid();
			});
			return value == target.val();
		}

	}

});

// deprecated, use $.validator.format instead
$.format = $.validator.format;

})(jQuery);

// ajax mode: abort
// usage: $.ajax({ mode: "abort"[, port: "uniqueport"]});
// if mode:"abort" is used, the previous request on that port (port can be undefined) is aborted via XMLHttpRequest.abort()
;(function($) {
	var pendingRequests = {};
	// Use a prefilter if available (1.5+)
	if ( $.ajaxPrefilter ) {
		$.ajaxPrefilter(function(settings, _, xhr) {
			var port = settings.port;
			if (settings.mode == "abort") {
				if ( pendingRequests[port] ) {
					pendingRequests[port].abort();
				}
				pendingRequests[port] = xhr;
			}
		});
	} else {
		// Proxy ajax
		var ajax = $.ajax;
		$.ajax = function(settings) {
			var mode = ( "mode" in settings ? settings : $.ajaxSettings ).mode,
				port = ( "port" in settings ? settings : $.ajaxSettings ).port;
			if (mode == "abort") {
				if ( pendingRequests[port] ) {
					pendingRequests[port].abort();
				}
				return (pendingRequests[port] = ajax.apply(this, arguments));
			}
			return ajax.apply(this, arguments);
		};
	}
})(jQuery);

// provides cross-browser focusin and focusout events
// IE has native support, in other browsers, use event caputuring (neither bubbles)

// provides delegate(type: String, delegate: Selector, handler: Callback) plugin for easier event delegation
// handler is only called when $(event.target).is(delegate), in the scope of the jquery-object for event.target
;(function($) {
	// only implement if not provided by jQuery core (since 1.4)
	// TODO verify if jQuery 1.4's implementation is compatible with older jQuery special-event APIs
	if (!jQuery.event.special.focusin && !jQuery.event.special.focusout && document.addEventListener) {
		$.each({
			focus: 'focusin',
			blur: 'focusout'
		}, function( original, fix ){
			$.event.special[fix] = {
				setup:function() {
					this.addEventListener( original, handler, true );
				},
				teardown:function() {
					this.removeEventListener( original, handler, true );
				},
				handler: function(e) {
					arguments[0] = $.event.fix(e);
					arguments[0].type = fix;
					return $.event.handle.apply(this, arguments);
				}
			};
			function handler(e) {
				e = $.event.fix(e);
				e.type = fix;
				return $.event.handle.call(this, e);
			}
		});
	};
	$.extend($.fn, {
		validateDelegate: function(delegate, type, handler) {
			return this.bind(type, function(event) {
				var target = $(event.target);
				if (target.is(delegate)) {
					return handler.apply(target, arguments);
				}
			});
		}
	});
})(jQuery);
/*!
 * jQuery throttle / debounce - v1.1 - 3/7/2010
 * http://benalman.com/projects/jquery-throttle-debounce-plugin/
 * 
 * Copyright (c) 2010 "Cowboy" Ben Alman
 * Dual licensed under the MIT and GPL licenses.
 * http://benalman.com/about/license/
 */

// Script: jQuery throttle / debounce: Sometimes, less is more!
//
// *Version: 1.1, Last updated: 3/7/2010*
// 
// Project Home - http://benalman.com/projects/jquery-throttle-debounce-plugin/
// GitHub       - http://github.com/cowboy/jquery-throttle-debounce/
// Source       - http://github.com/cowboy/jquery-throttle-debounce/raw/master/jquery.ba-throttle-debounce.js
// (Minified)   - http://github.com/cowboy/jquery-throttle-debounce/raw/master/jquery.ba-throttle-debounce.min.js (0.7kb)
// 
// About: License
// 
// Copyright (c) 2010 "Cowboy" Ben Alman,
// Dual licensed under the MIT and GPL licenses.
// http://benalman.com/about/license/
// 
// About: Examples
// 
// These working examples, complete with fully commented code, illustrate a few
// ways in which this plugin can be used.
// 
// Throttle - http://benalman.com/code/projects/jquery-throttle-debounce/examples/throttle/
// Debounce - http://benalman.com/code/projects/jquery-throttle-debounce/examples/debounce/
// 
// About: Support and Testing
// 
// Information about what version or versions of jQuery this plugin has been
// tested with, what browsers it has been tested in, and where the unit tests
// reside (so you can test it yourself).
// 
// jQuery Versions - none, 1.3.2, 1.4.2
// Browsers Tested - Internet Explorer 6-8, Firefox 2-3.6, Safari 3-4, Chrome 4-5, Opera 9.6-10.1.
// Unit Tests      - http://benalman.com/code/projects/jquery-throttle-debounce/unit/
// 
// About: Release History
// 
// 1.1 - (3/7/2010) Fixed a bug in <jQuery.throttle> where trailing callbacks
//       executed later than they should. Reworked a fair amount of internal
//       logic as well.
// 1.0 - (3/6/2010) Initial release as a stand-alone project. Migrated over
//       from jquery-misc repo v0.4 to jquery-throttle repo v1.0, added the
//       no_trailing throttle parameter and debounce functionality.
// 
// Topic: Note for non-jQuery users
// 
// jQuery isn't actually required for this plugin, because nothing internal
// uses any jQuery methods or properties. jQuery is just used as a namespace
// under which these methods can exist.
// 
// Since jQuery isn't actually required for this plugin, if jQuery doesn't exist
// when this plugin is loaded, the method described below will be created in
// the `Cowboy` namespace. Usage will be exactly the same, but instead of
// $.method() or jQuery.method(), you'll need to use Cowboy.method().

(function(window,undefined){
  '$:nomunge'; // Used by YUI compressor.
  
  // Since jQuery really isn't required for this plugin, use `jQuery` as the
  // namespace only if it already exists, otherwise use the `Cowboy` namespace,
  // creating it if necessary.
  var $ = window.jQuery || window.Cowboy || ( window.Cowboy = {} ),
    
    // Internal method reference.
    jq_throttle;
  
  // Method: jQuery.throttle
  // 
  // Throttle execution of a function. Especially useful for rate limiting
  // execution of handlers on events like resize and scroll. If you want to
  // rate-limit execution of a function to a single time, see the
  // <jQuery.debounce> method.
  // 
  // In this visualization, | is a throttled-function call and X is the actual
  // callback execution:
  // 
  // > Throttled with `no_trailing` specified as false or unspecified:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // > X    X    X    X    X    X        X    X    X    X    X    X
  // > 
  // > Throttled with `no_trailing` specified as true:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // > X    X    X    X    X             X    X    X    X    X
  // 
  // Usage:
  // 
  // > var throttled = jQuery.throttle( delay, [ no_trailing, ] callback );
  // > 
  // > jQuery('selector').bind( 'someevent', throttled );
  // > jQuery('selector').unbind( 'someevent', throttled );
  // 
  // This also works in jQuery 1.4+:
  // 
  // > jQuery('selector').bind( 'someevent', jQuery.throttle( delay, [ no_trailing, ] callback ) );
  // > jQuery('selector').unbind( 'someevent', callback );
  // 
  // Arguments:
  // 
  //  delay - (Number) A zero-or-greater delay in milliseconds. For event
  //    callbacks, values around 100 or 250 (or even higher) are most useful.
  //  no_trailing - (Boolean) Optional, defaults to false. If no_trailing is
  //    true, callback will only execute every `delay` milliseconds while the
  //    throttled-function is being called. If no_trailing is false or
  //    unspecified, callback will be executed one final time after the last
  //    throttled-function call. (After the throttled-function has not been
  //    called for `delay` milliseconds, the internal counter is reset)
  //  callback - (Function) A function to be executed after delay milliseconds.
  //    The `this` context and all arguments are passed through, as-is, to
  //    `callback` when the throttled-function is executed.
  // 
  // Returns:
  // 
  //  (Function) A new, throttled, function.
  
  $.throttle = jq_throttle = function( delay, no_trailing, callback, debounce_mode ) {
    // After wrapper has stopped being called, this timeout ensures that
    // `callback` is executed at the proper times in `throttle` and `end`
    // debounce modes.
    var timeout_id,
      
      // Keep track of the last time `callback` was executed.
      last_exec = 0;
    
    // `no_trailing` defaults to falsy.
    if ( typeof no_trailing !== 'boolean' ) {
      debounce_mode = callback;
      callback = no_trailing;
      no_trailing = undefined;
    }
    
    // The `wrapper` function encapsulates all of the throttling / debouncing
    // functionality and when executed will limit the rate at which `callback`
    // is executed.
    function wrapper() {
      var that = this,
        elapsed = +new Date() - last_exec,
        args = arguments;
      
      // Execute `callback` and update the `last_exec` timestamp.
      function exec() {
        last_exec = +new Date();
        callback.apply( that, args );
      };
      
      // If `debounce_mode` is true (at_begin) this is used to clear the flag
      // to allow future `callback` executions.
      function clear() {
        timeout_id = undefined;
      };
      
      if ( debounce_mode && !timeout_id ) {
        // Since `wrapper` is being called for the first time and
        // `debounce_mode` is true (at_begin), execute `callback`.
        exec();
      }
      
      // Clear any existing timeout.
      timeout_id && clearTimeout( timeout_id );
      
      if ( debounce_mode === undefined && elapsed > delay ) {
        // In throttle mode, if `delay` time has been exceeded, execute
        // `callback`.
        exec();
        
      } else if ( no_trailing !== true ) {
        // In trailing throttle mode, since `delay` time has not been
        // exceeded, schedule `callback` to execute `delay` ms after most
        // recent execution.
        // 
        // If `debounce_mode` is true (at_begin), schedule `clear` to execute
        // after `delay` ms.
        // 
        // If `debounce_mode` is false (at end), schedule `callback` to
        // execute after `delay` ms.
        timeout_id = setTimeout( debounce_mode ? clear : exec, debounce_mode === undefined ? delay - elapsed : delay );
      }
    };
    
    // Set the guid of `wrapper` function to the same of original callback, so
    // it can be removed in jQuery 1.4+ .unbind or .die by using the original
    // callback as a reference.
    if ( $.guid ) {
      wrapper.guid = callback.guid = callback.guid || $.guid++;
    }
    
    // Return the wrapper function.
    return wrapper;
  };
  
  // Method: jQuery.debounce
  // 
  // Debounce execution of a function. Debouncing, unlike throttling,
  // guarantees that a function is only executed a single time, either at the
  // very beginning of a series of calls, or at the very end. If you want to
  // simply rate-limit execution of a function, see the <jQuery.throttle>
  // method.
  // 
  // In this visualization, | is a debounced-function call and X is the actual
  // callback execution:
  // 
  // > Debounced with `at_begin` specified as false or unspecified:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // >                          X                                 X
  // > 
  // > Debounced with `at_begin` specified as true:
  // > ||||||||||||||||||||||||| (pause) |||||||||||||||||||||||||
  // > X                                 X
  // 
  // Usage:
  // 
  // > var debounced = jQuery.debounce( delay, [ at_begin, ] callback );
  // > 
  // > jQuery('selector').bind( 'someevent', debounced );
  // > jQuery('selector').unbind( 'someevent', debounced );
  // 
  // This also works in jQuery 1.4+:
  // 
  // > jQuery('selector').bind( 'someevent', jQuery.debounce( delay, [ at_begin, ] callback ) );
  // > jQuery('selector').unbind( 'someevent', callback );
  // 
  // Arguments:
  // 
  //  delay - (Number) A zero-or-greater delay in milliseconds. For event
  //    callbacks, values around 100 or 250 (or even higher) are most useful.
  //  at_begin - (Boolean) Optional, defaults to false. If at_begin is false or
  //    unspecified, callback will only be executed `delay` milliseconds after
  //    the last debounced-function call. If at_begin is true, callback will be
  //    executed only at the first debounced-function call. (After the
  //    throttled-function has not been called for `delay` milliseconds, the
  //    internal counter is reset)
  //  callback - (Function) A function to be executed after delay milliseconds.
  //    The `this` context and all arguments are passed through, as-is, to
  //    `callback` when the debounced-function is executed.
  // 
  // Returns:
  // 
  //  (Function) A new, debounced, function.
  
  $.debounce = function( delay, at_begin, callback ) {
    return callback === undefined
      ? jq_throttle( delay, at_begin, false )
      : jq_throttle( delay, callback, at_begin !== false );
  };
  
})(this);
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
/*global cache_register_onbeforerestorevalues:true cache_register_onbeforeunload:true */
/*jshint sub:true */
var string_ci_ai = function(s) {
	var r=s.toLowerCase();
	r = r.replace(new RegExp("[àáâãäå]", "g"),"a");
	r = r.replace(new RegExp("æ","g"),"ae");
	r = r.replace(new RegExp("ç","g"),"c");
	r = r.replace(new RegExp("[èéêë]","g"),"e");
	r = r.replace(new RegExp("[ìíîï]","g"),"i");
	r = r.replace(new RegExp("ñ","g"),"n");                
	r = r.replace(new RegExp("[òóôõö]","g"),"o");
	r = r.replace(new RegExp("","g"),"oe");
	r = r.replace(new RegExp("[ùúûü]","g"),"u");
	r = r.replace(new RegExp("[ýÿ]","g"),"y");
	return r;
};
window['string_ci_ai'] = string_ci_ai;

var default_cache_search_fn = function($, cache, prop, regex_pre, regex_post) {
	prop = prop || 'value';
	regex_pre = regex_pre || '';
	regex_post = regex_post || '';
	return function (request, response) {
		if (cache.term && (new RegExp(regex_pre + $.ui.autocomplete.escapeRegex(cache.term) + regex_post, "i")).test(request.term) && cache.content && cache.content.length < 13) {
			var matcher = new RegExp(regex_pre + $.ui.autocomplete.escapeRegex(request.term) + regex_post, "i");
			response($.grep(cache.content, function(value) {
				return matcher.test(string_ci_ai(value[prop]));
			}));
			return true;
		}

		return false;
	};
};

window['default_cache_search_fn'] = default_cache_search_fn;

var create_caching_source_fn = function($, url, cache, prop, cache_search_fn) {
	cache = cache || {};
	prop = prop || 'value';
	cache_search_fn = cache_search_fn || default_cache_search_fn($, cache, prop);
	return function (request, response, override_url) {
		request.term = string_ci_ai(request.term);
		if (cache.term === request.term && cache.content) {
			response(cache.content);
			return;
		}
		if (cache_search_fn(request, response)) {
			return;
		}
		$.ajax({
			url: override_url || url,
			dataType: "json",
			data: request,
			cache: false,
			success: function(data) {
				cache.term = request.term;
				cache.content = data;
				response(data);
			}
		});
	};
};

window['create_caching_source_fn'] = create_caching_source_fn;

var init_community_autocomplete = function($, id, url, minLength, cmidfield) {
	var cache = {};
	if (cmidfield) {
		cmidfield = $(cmidfield);
	}
	if (cmidfield && !cmidfield.length) {
		cmidfield = null;
	}
	var input_el = $("#" + id).
		autocomplete({
			focus:function(event,ui) {
				return false;
			},
			select: function(event, ui) {
				input_el.data({
					chkid: ui.item.chkid,
					display: ui.item.value
				});
			},
			source: create_caching_source_fn($,url,cache),
			minLength: minLength}).
		keypress(function (evt) {
			if (evt.keyCode == '13') {
				evt.preventDefault();
				input_el.autocomplete('close');
			}
		});

	if (cmidfield) {
		input_el.parents('form').on('submit', function() {
			var input_el_val = input_el.val();
			if (input_el.data('display') === input_el_val) {
				cmidfield.val(input_el.data('chkid'));
				return;
			}
			if (cache.content) {
				var testvalue = string_ci_ai(input_el_val);
				var values = $.grep(cache.content, function(value) {
					return string_ci_ai(value['value']) === testvalue;
				});
				if (values.length === 1) {
					cmidfield.val(values[0].chkid);
					input_el.data({chkid: values[0].chkid, display: values[0].value}).val(values[0].value);
					return;
				}
			}

			cmidfield.val('');
		});

		cache_register_onbeforerestorevalues(function(csh) {
			if (!input_el.length) {
				return;
			}
			var data = csh['autocomplete_data_' + input_el[0].id];
			if (data) {
				input_el.data(data);
			}
		});

		cache_register_onbeforeunload(function(csh) {
			if (!input_el.length) {
				return;
			}
			var data = input_el.data();
			if (data.display && data.chkid) {
				csh['autocomplete_data_' + input_el[0].id] = {
					display: data.display,
					chkid: data.chkid
				};
			}
		});
	}

	

};

window['init_community_autocomplete'] = init_community_autocomplete;
})();

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
window['entryform'] = window['entryform'] || {};

window['create_checklist_onbefore_fns'] = function($, field, added_values, add_new_value) {
	cache_register_onbeforeunload(function(cache) {
		cache[field + '_added'] = added_values;
	});
	cache_register_onbeforerestorevalues(function (cache) {
		var array = cache[field + '_added'];
		if (!array) {
			return;
		}
		$.each(array, function (index, item) {
			add_new_value(item.chkid, item.display, "");
		});
	});
};

window['basic_chk_add_html'] = function($, field) {
	return function (chkid, display) {
		var new_row = $('<tr>').
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_ID_' + chkid,
							type: 'checkbox',
							checked: true,
							defaultChecked: true,
							name: field + '_ID',
							value: chkid
							})
					).
					append(document.createTextNode(' ' + display))
				).
				append($('<td>').
					append($('<input>').
						prop({
							id: field + '_NOTES_' + chkid,
							name: field + '_NOTES_' + chkid,
							size: entryform.chk_notes_size,
							maxlength: entryform.chk_notes_maxlen
							})
					)
				);
		$('#' + field + '_existing_add_table').append(new_row);
		return new_row.find('input[type="checkbox"]')[0];
		
	};
};

var already_added_checklists = {};
var do_autocomplete_call = function(field) {
		$('#NEW_' + field).autocomplete(already_added_checklists[field]);
};
window['init_autocomplete_checklist'] = function($, options) {
	var field = options.field;

	if (already_added_checklists[field]) {
		do_autocomplete_call(field);
		return;
	}

	var source = options.source;
	options.minLength = options.minLength || 1;
	options.delay = options.delay || 300;
	options.add_new_html = options.add_new_html || basic_chk_add_html($, field);
	options.match_prop = options.match_prop || 'value';
	options.txt_not_found = options.txt_not_found || 'Not Found';

	var delegate_root = $(options.delegate_root || document);

	var added_values = options.added_values || [];
	var add_new_value = function(chkid, display, label) {
		//console.log('add');
		var existing_chk = document.getElementById(field + '_ID_' + chkid);
		if (existing_chk) {
			existing_chk.checked = true;
			if (options.after_add_new_value) {
				options.after_add_new_value.call(existing_chk);
			}
			//already exists
			return;
		}

		added_values.push({chkid: chkid, display: display, label: label});

		var new_chk = options.add_new_html(chkid, display, label);
		if (options.after_add_new_value) {
			options.after_add_new_value.call(new_chk);
		}

	};

	create_checklist_onbefore_fns($, field, added_values, add_new_value);

	var cache = {};

	var after_add = function(evt) {
		//console.log('after add');
		$('#NEW_' + field).
			data({chkid: "", display: "", label: ""}).
			prop('value', "").
			focus();

		$('#' + field + '_error').hide('slow', function() {
				$(this).remove();
		});
	};

	var look_for_value = null;
	var source_fn = null;
	(function (source) {
		var array, url;
		if ( $.isArray(source) ) {
			array = source;
			source_fn = function( request, response ) {
				// escape regex characters
				var matcher = new RegExp( $.ui.autocomplete.escapeRegex(string_ci_ai(request.term)));
				response( $.grep( array, function(value) {
					return matcher.test( string_ci_ai(value[options.match_prop] || value));
				}) );
			};
			look_for_value = function(invalue, response) {
				var inputvalue = string_ci_ai(invalue);
				var values = $.grep(array, function(value) {
							return string_ci_ai(string_ci_ai(value[options.match_prop] || value)) === inputvalue;
						});
				if (values.length === 1) {
					response(values[0]);
					return true;
				} else {
					response();
				}

			};
		} else if ( typeof source === "string" ) {
			url = source;
			source_fn = create_caching_source_fn($, url, cache, options.match_prop),
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
			};
		} else {
			source_fn = source;
			look_for_value = options.look_for_fn;
		}
	})(source);

	var do_show_error = function() {
		if ($("#" + field + "_error").length === 0) {
			//console.log('error');
			$('#' + field + '_new_input_table').before($('<p>').
					hide().
					addClass('Alert').
					prop('id', field + '_error').
					append(document.createTextNode(options.txt_not_found)));

			$("#" + field + "_error").show('slow');
		}
	};

	var on_add_click = function(evt) {
		//console.log('onclick');
		var newfield = $('#NEW_' + field);
		var chkid = newfield.data('chkid');
		var display = newfield.data('display');
		var label = newfield.data('label');
		var newfieldval = newfield[0].value;
		if (chkid && display && display == newfieldval) {
			add_new_value(chkid, display, label);
			after_add();
			return false;

		}
		look_for_value(newfield[0].value, function(item) {
			if (item) {
				add_new_value(item.chkid, item.value, item.label);
				after_add();
			} else {
				do_show_error();
			}
		});
		return false;

	};
	delegate_root.on('click', "#add_" + field, on_add_click);

	already_added_checklists[field] = {
		focus: function(e,ui) {
			return false;
		},
		source: source_fn,
		minLength: options.minLength,
		delay: options.delay,
		select: function(evt, ui) {
			$('#NEW_' + field).data({
				chkid: ui.item.chkid,
				display: ui.item.value,
				label: ui.item.label
				});
		}
	};

	delegate_root.on('keypress', '#NEW_' + field, function (evt) {
			if (evt.keyCode == '13') {
				evt.preventDefault();
				$('#NEW_' + field).autocomplete('close');
				$('#add_' + field).trigger('click');
			}
		});

	do_autocomplete_call(field);

};
window['init_languages'] = function($, txt_not_found) {
	var add_button = null, template = null, table = $('#LN_existing_add_table');
	var change_fn = function() {
		var self = $(this), entry = self.parents('.language-entry'), details = entry.find('.language-details-notes');
		if (this.checked) {
			details.slideDown();
		} else {
			details.slideUp();
		}
	}
	var options = {
		field: 'LN',
		source: entryform.languages_source,
		txt_not_found: txt_not_found,
		after_add_new_value: change_fn,
		add_new_html: function(chkid, display) {
			if (add_button === null) {
				add_button = $('#add_LN');
				template = add_button.data('newTemplate');
			}

			var html = template.replace(/LANGNAMELANGNAME/g, display).replace(/IDIDID/g, chkid);
			table.append(html);

		}

	};
	init_autocomplete_checklist($, options);
	table.on('change', '.language-primary', change_fn).uitooltip({
		items: '[data-help-text]',
		content: function() {
			var self = $(this);
			return '<div class="language-help-text">' + self.data('helpText') + "</div>";
		},
		position: {
			my: "center bottom-20",
			at: "center top",
			using: function( position, feedback ) {
			  $( this ).css( position );
			  $( "<div>" )
				.addClass( "arrow" )
				.addClass( feedback.vertical )
				.addClass( feedback.horizontal )
				.appendTo( this );
			}
		}
	});
	
	window['languages_check_state'] = change_fn;
	
};

})();
﻿// =========================================================================================
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
/*global
 init_autocomplete_checklist:true
*/
	jQuery.fn.autoShorten = function(max, more, less) {
		return this.each(function(){
			max = max || 350;
			more = more || '[read more]';
			less = less || '[less]';
			var self = $(this), html = self.html();
			if (html.length > max) {
				var words = html.substring(0,max).split(" ");
				var shortText = $('<div>').html(words.slice(0, words.length - 1).join(" ") + ' ').append('<span class="ellipse-toggle SimulateLink">&hellip; ' + more +'</span>').html();
				$(this).data('replacementText', html + ' <span class="ellipse-toggle SimulateLink">' + less + '</span>')
				.html(shortText)
				.on('click', 'span.ellipse-toggle', function() {
					var tempText = self.html();
					self.html(self.data('replacementText'));
					self.data('replacementText', tempText);
				});
			}
		});
	};

	var add_new_html = function($, field, name) {
		name = name || (field + '_ID');
		return function(chkid, display) {
			var button = $('#add_' + field), my_cell = button.parent(), my_row = my_cell.parent(), last_row = my_row.prev('tr'),
				col_target = parseInt(my_cell.prop("colspan"), 10), last_row_cols = last_row.find('td').length;
			if (!last_row.length || col_target === last_row_cols) {
				last_row = $('<tr>').insertBefore(my_row);
			}
			last_row.append(
				$('<td>').append(
					$('<label>').
					text(' ' + display).
					prepend(
						$('<input type="checkbox" checked>').prop({
							id: field +'_ID_' + chkid,
							value: chkid,
							name: name
						})
					)
				)
			);
		};
	};

	var init_user_autocomplete = function(url, txt_not_found) {
		init_autocomplete_checklist($, {
			source: url,
			field: 'reminder_user',
			add_new_html: add_new_html($, 'reminder_user'),
			txt_not_found: txt_not_found
		});
	};

	var initialize_reminders_form = function() {
		$(document).on('click', '#add_reminder_agency', function(evt) {
			evt.preventDefault();
			var agency_select = $('#NEW_reminder_agency');
			var agency_add_html = add_new_html($, 'reminder_agency');
			var val = agency_select[0].value;
			if (val) {
				var target_input = $('#reminder_agency_ID_' + val);
				if (target_input.length) {
					target_input.prop('checked', true);
				} else {
					agency_add_html(val, val);
				}
				agency_select.find('option').first().prop({selected: true});
			}
			return false;
		});
		$.each(['NUM', 'VNUM'], function(index, field) {
			$(document).on('click', '#add_' + field, function(evt) {
				evt.preventDefault();
				var field_input = $('#NEW_' + field);
				var field_add_html = add_new_html($, field, field);
				var val = field_input[0].value;
				if (val) {
					var target_input = $('#' + field + '_ID_' + val);
					if (target_input.length) {
						target_input.prop('checked', true);
					} else {
						field_add_html(val, val);
					}
				}
				field_input[0].value = '';
				return false;
			}).on('keypress', '#NEW_' + field, function(evt) {
				if (evt.keyCode === 13) {
					evt.preventDefault();
					$('#add_' + field).trigger('click');
				}
			});

		});
	};
	var hide_empty_headers = function() {
		$('.reminder-section').each(function() {
			if (!$(this).find('.reminder-item:not(.dismissed)').length) {
				$(this).hide();
			}
		});
	};
	var initialize_reminder_list = function(existing_reminders, txt_more, txt_less) {
		$('#reminder-items-inactive').hide();
		hide_empty_headers();
		$('#reminder-header-inactive').addClass("SimulateLink").prepend($('<span class="ui-icon ui-icon-triangle-1-e" style="display: inline-block">'));
		$('#reminder-add-link, #reminder-show-dismissed, #show-closed-notices').uibutton();

		if (!$('#existing-reminders-page').addClass('hide-dismissed').find('.dismissed').length) {
			$('#reminder-dismiss-ui').hide();
		}
		existing_reminders.find('.AutoShorten').autoShorten(null, txt_more, txt_less);
	};

	window['initialize_reminders'] = function(title, userurl, reminder_url, reminder_dismiss_url, txt_colon, txt_more, txt_less, txt_loading, delete_link, txt_not_found) {
		var reminder_dialog = null;
		init_user_autocomplete(userurl, txt_not_found);
		initialize_reminders_form();
		initialize_reminder_list($('#existing-reminders-page'), txt_more, txt_less);
		var reminders_list_div = $('#existing-reminders-page').on('click', '#reminder-header-inactive', function() {
			var inactive = $('#reminder-items-inactive'),
				icon = $(this).find('span.ui-icon');
			if ( inactive.is(':hidden') ) {
				inactive.slideDown('slow');
				icon.removeClass('ui-icon-triangle-1-e').addClass('ui-icon-triangle-1-s');
			} else {
				inactive.slideUp('slow');
				icon.removeClass('ui-icon-triangle-1-s').addClass('ui-icon-triangle-1-e');
			}
		}).on('click', '#reminder-show-dismissed', function() {
			if (this.checked) {
				reminders_list_div.removeClass('hide-dismissed');
				$('.reminder-section').show();
			} else {
				reminders_list_div.addClass('hide-dismissed');
				hide_empty_headers();
			}
		}).uitooltip({
			items: 'span.details-link',
			content: function() {
				return $(this).data('tooltip');
			}
		}).on('click', '.dismiss-reminder,.restore-reminder', function() {
			var self = $(this), is_dismiss = self.is('.dismiss-reminder'),
				reminder_id = self.data('reminderId');
			$.when($.ajax(reminder_dismiss_url.replace('IDIDID', reminder_id), {
				dataType: 'json',
				type: 'post',
				cache: false,
				data: {dismiss: is_dismiss ? 'on' : null, json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					var row = self.parents('tr').first();
					if (data.dismissed) {
						row.addClass('dismissed');
						$('#reminder-dismiss-ui').show();
					} else {
						row.removeClass('dismissed');
						if (!$('#existing-reminders-page .dismissed').length) {
							$('#reminder-dismiss-ui').hide();
						}
					}
				} else {
					/// XXX
				}
			});

		});
		var reminders_popup_link = $('#reminders').click(function() {
			var existing_reminders = $('#existing-reminders-page').empty().text(txt_loading);
			$.when($.ajax(reminder_url, {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					existing_reminders[0].innerHTML = data.reminders;
					initialize_reminder_list(existing_reminders, txt_more, txt_less);
					if (reminder_dialog.height() > $(window).height() - 10) {
						reminder_dialog.dialog('option', 'height', $(window).height() - 10);
					}
					reminder_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			if ( ! reminder_dialog ) {
				reminder_dialog = $('#reminder-dialog').dialog({
					title: title,
					width: 500,
					maxHeight: $(window).height() - 10,
					open: function() {
						$(this).dialog({position: "center"});
					}
				});
				$(window).resize($.throttle(250, function() {
					reminder_dialog.dialog('option', 'maxHeight', $(this).height() - 10);
				}));
			} else {
				reminder_dialog.dialog('option', 'height', 'auto');
				reminder_dialog.dialog('open');
			}
		});
		var reminder_edit_dialog = null;
		$('#reminder-dialog').on('click', '.edit-link', function(evt) {
			evt.preventDefault();
			$('#reminder-edit-dialog').empty().text(txt_loading);
			$.when($.ajax(this.href, {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.find('.DatePicker').css('zIndex', reminder_edit_dialog.css('zIndex')).autodatepicker();
					init_user_autocomplete(userurl);
					reminder_edit_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_edit_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			if (!reminder_edit_dialog) {
				reminder_edit_dialog = $('#reminder-edit-dialog').dialog({width: 'auto', height: 'auto'});
			} else {
				reminder_edit_dialog.dialog('open');
			}
			return false;
		});
		$('#reminder-edit-dialog').on('submit', 'form', function(evt) {
			evt.preventDefault();
			var form = $(this);
			$.when($.ajax(form.prop('action'), {
				dataType: 'json',
				data: form.serialize(),
				type: form.prop('method')
			})).done(function(data) {
				if (!data.success) {
					//error condition
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.find('.DatePicker').css('zIndex', reminder_edit_dialog.css('zIndex')).autodatepicker();
					init_user_autocomplete(userurl);
				} else {
					reminders_popup_link.trigger('click');
					reminder_edit_dialog.dialog('close');
				}
			});
			return false;
		}).on('click', '#delete-reminder', function(evt) {
			evt.preventDefault();
			$('#reminder-edit-dialog').empty().text(txt_loading);
			$.when($.ajax(delete_link.replace('IDIDID', $(this).data('reminderId')), {
				dataType: 'json',
				type: 'get',
				cache: false,
				data: {json_api: 'on'}
			})).done(function(data) {
				if (data.success) {
					reminder_edit_dialog[0].innerHTML = data.form;
					reminder_edit_dialog.dialog('option', 'position', 'center');
				} else {
					reminder_edit_dialog.empty().append($('<p class="Alert"></p>').text(data.ErrMsg));
				}
			});
			return false;
		});
	};
})();
