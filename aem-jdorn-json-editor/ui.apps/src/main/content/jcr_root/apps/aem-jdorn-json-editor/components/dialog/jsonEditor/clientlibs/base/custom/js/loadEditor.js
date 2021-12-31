var JSONEditorModule = window.JSONEditorModule;
var JSONEditor = JSONEditorModule.JSONEditor;

(function ($, $document) {
    "use strict";
    var schemaPreviewEditorCreated = false;
    var schemaPreviewMode = false;
    var editorLookup = {};
    var buildEditors = function () {
        JSONEditor.defaults.options.theme = 'bootstrap3';
        JSONEditor.defaults.options.iconlib = 'fontawesome4';
        JSONEditor.defaults.options.no_additional_properties = true;
        //JSONEditor.defaults.options.disable_edit_json = true;
        JSONEditor.defaults.options.show_errors = "always";
        $('coral-tabview.json-editor-multifield-noncomposite-granite,coral-tabview.json-editor-granite').each(function () {
            buildEditor(this);
        });
    };
    
    var getAutoCompleteMarkup = function (schemaRef) {
		return ('<foundation-autocomplete class="coral-Form-field coral-path-picker-jsoneditor name="' + schemaRef + '" pickersrc="/mnt/overlay/granite/ui/content/coral/foundation/form/pathfield/picker.html?_charset_=utf-8&path={value}&root=%2fcontent&filter=hierarchyNotFile&selectionCount=single" data-foundation-validation="" role="combobox">' +
			'<div class="foundation-autocomplete-inputgroupwrapper">' +
			'  <div class="coral-InputGroup">' +
			'<input is="coral-textfield" class="coral3-Textfield coral-InputGroup-input" autocomplete="off" placeholder="Select location using AEM Path Browser" id="' + schemaRef + '" aria-invalid="false">' +
			'<span class="coral-InputGroup-button">' +
			'<button is="coral-button" class="coral3-Button coral3-Button--secondary" size="M" variant="secondary" title="Open Selection Dialog" type="button" aria-label="Open Selection Dialog">' +
			'   <coral-icon class="coral3-Icon coral3-Icon--sizeS coral3-Icon--select" icon="select" size="S" role="img" aria-label="select"></coral-icon>' +
			'   <coral-button-label></coral-button-label>' +
			'</button>' +
			'</span>' +
			'</div>' +
			'</div>' +
			'<coral-overlay foundation-autocomplete-suggestion="" class="foundation-picker-buttonlist coral3-Overlay" data-foundation-picker-buttonlist-src="/mnt/overlay/granite/ui/content/coral/foundation/form/pathfield/suggestion{.offset,limit}.html?_charset_=utf-8&root=%2fcontent&filter=hierarchyNotFile{&query}" aria-hidden="true" style="display: none;"></coral-overlay>' +
			'<coral-taglist foundation-autocomplete-value="" name="' + schemaRef + '" class="coral3-TagList" aria-disabled="false" role="listbox" aria-live="off" aria-atomic="false" aria-relevant="additions" aria-readonly="false" aria-invalid="false" aria-required="false"><object aria-hidden="true" tabindex="-1" style="display:block; position:absolute; top:0; left:0; height:100%; width:100%; opacity:0; overflow:hidden; z-index:-100;" type="text/html" data="about:blank">​</object></coral-taglist>' +
			'</foundation-autocomplete>')
	};
    
    var buildEditor = function (editorInstance) {
        var $editorInstance = $(editorInstance);
        var $editorJson = $($editorInstance.find('textarea[data-area="json"]'));
        var $editorSchema = $($editorInstance.find('textarea[data-area="schema"]'));
        var schemaPath = $editorJson.data('schemapath');
        var useDamFallback = $editorJson.data('usedamasfallback');
        var jsonSchema = {};
        if (schemaPath) {
            var resourcePath = $editorJson.data('containingcomponentpath');
            //$.getJSON({dataType:'json',url:"/apps/spa-poc/components/content/header-json/./schema.json",success:function(response){jsonSchema=response},error:function(xhr, status, errorThrown ){console.error(xhr, status, errorThrown );return;}});
            function getJson(jsonPath) {
                $.getJSON({
                    async: false
                    , dataType: 'json'
                    , url: jsonPath
                    , success: function (response) {
                        jsonSchema = response;
                    }
                    , error: function (xhr, status, errorThrown) {
                        console.error(xhr, status, errorThrown);
                        return;
                    }
                });
            }
            var initialJsonPath = schemaPath.match(/^\/apps/) ? schemaPath : (resourcePath + "/" + schemaPath);
            if (_.isEqual(jsonSchema, {})) {
                getJson(initialJsonPath);
                if (_.isEqual(jsonSchema, {}) && useDamFallback) {
                    var fallbackJsonPath = "/content/dam/aem-jdorn-json-editor" + initialJsonPath;
                    getJson(fallbackJsonPath);
                }
            }
        }
        else {
            jsonSchema = JSON.parse($editorSchema.val());
        }
        if (JSON.stringify(jsonSchema) !== "{}") {
            $editorSchema.val(jsonSchema ? JSON.stringify(jsonSchema, undefined, 2) : '{}');
            var startVal = $editorJson.val().trim() || "{}";
            var startValStr = JSON.stringify(JSON.parse(startVal));
            var editorOptions = {
                schema: jsonSchema
            };
            if (startVal) {
                startVal = JSON.parse(startVal);
                if (startVal) {
                    editorOptions.startval = startVal;
                }
            }
            var editor = null;
            var editorCreatedOrUpdated = false;
            if (!schemaPreviewMode || (schemaPreviewMode && !schemaPreviewEditorCreated)) {
                var editorElement = $editorInstance.find("[id^=jsonEditor_]")[0];
                editor = new JSONEditor(editorElement, editorOptions);
                editorLookup[editorElement.id] = editor;
                schemaPreviewEditorCreated = true;
                editorCreatedOrUpdated = true;
            }
            else {
                editor = editorLookup["jsonEditor_JDorn"];
                if (!_.isEqual(editor.schema, jsonSchema)) {
                    var newEditorOptions = {
                        schema: jsonSchema
                    }
                    editor.destroy();
                    var curVal = $editorJson.val();
                    if (curVal !== "{}") {
                        curVal = JSON.parse(curVal);
                        newEditorOptions.startval = curVal;
                    }
                    editor = new JSONEditor($("#jsonEditor_JDorn")[0], newEditorOptions);
                    editorLookup["jsonEditor_JDorn"] = editor;
                    editorCreatedOrUpdated = true;
                }
            }
            if (editorCreatedOrUpdated) {
                //window.editors = window.editors || [];
                //window.editors.push(editor);
                //editor.setValue($('[name="./contentJSON"]').val() || {make: "Ford", model: "", year: 2001, safety: 4});
                //var editorSetupDone = false;
                var isMultifieldNonCompositeReplacement = $editorInstance.is('.json-editor-multifield-noncomposite-granite');
                editor.on('change', function () {
                    var modifiedValStr = JSON.stringify(this.getValue());
                    if (startValStr !== modifiedValStr) {
                        $editorInstance.find('coral-alert').show();
                    }
                    else $editorInstance.find('coral-alert').hide();
                    var editorNewValAsIs = this.getValue();
                    $editorJson.val(JSON.stringify(editorNewValAsIs, undefined, 2) || {});
                    if (isMultifieldNonCompositeReplacement) {
                        var $multiFieldValueSection = $($editorJson.closest('coral-panel').find('section[id^="multifieldJson_"]')[0]);
                        if ($multiFieldValueSection) {
                            $multiFieldValueSection.empty();
                            var editor
                            if (editorNewValAsIs instanceof Array) {
                                var multiFieldName = $multiFieldValueSection.data("fieldname");
                                for (var i = 0; i < editorNewValAsIs.length; i++) {
                                    $multiFieldValueSection.append($('<input/>').attr({
                                        "name": multiFieldName
                                        , "value": JSON.stringify(editorNewValAsIs[i])
                                        , "type": "hidden"
                                    }));
                                }
                                $multiFieldValueSection.append($('<input/>').attr({
                                    "name": multiFieldName + "@Delete"
                                    , "type": "hidden"
                                }));
                            }
                        }
                    }
                    if ($editorInstance.find('input.coral-path-picker-jsoneditor').length != $editorInstance.find('foundation-autocomplete.coral-path-picker-jsoneditor').length) {
                        $editorInstance.find('input.coral-path-picker-jsoneditor').each(function (pickerFieldIndex, pickerField) {
                            var $childEditor = $($(pickerField).closest('[data-schemapath]'));
                            if ($childEditor.find('foundation-autocomplete.coral-path-picker-jsoneditor').length < 1) {
                                $childEditor.find('div.form-group').append(getAutoCompleteMarkup($childEditor.attr('data-schemapath')));
                                $(pickerField).hide();
                                var childEditorInstance = editor.getEditor($childEditor.attr('data-schemapath'));
                                $childEditor.find('foundation-autocomplete.coral-path-picker-jsoneditor').val(childEditorInstance.getValue());
                                $childEditor.find('foundation-autocomplete.coral-path-picker-jsoneditor').on('foundation-field-change', function (locationChangeEvent) {
                                    var newValue = locationChangeEvent.target.value || '';
                                    childEditorInstance.setValue(newValue)
                                });
                            }
                        });
                    }
                });
            }
            $editorInstance.closest('.coral-Form-fieldwrapper').find('coral-alert[data-error-type="schema_error"]').hide();
        }
        else {
            $editorInstance.closest('.coral-Form-fieldwrapper').find('coral-alert[data-error-type="schema_error"]').show();
            $editorInstance.hide();
        }
    }
    $document.on("dialog-ready", buildEditors);
    // JSON Schema Editor Component Re-render call
    $document.on("coral-tablist:change", function (e) {
        if (e.detail.selection.id.match(/json-editor/)) {
            schemaPreviewMode = true;
            buildEditors();
        }
    });
})
($, $(document));