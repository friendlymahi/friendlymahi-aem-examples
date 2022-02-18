/*******************************************************************************
 * ADOBE CONFIDENTIAL
 * __________________
 *
 * Copyright 2020 Adobe Systems Incorporated
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 ******************************************************************************/
"use strict";
use(function () {
    let item = {};

    let superType = "granite/ui/components/coral/foundation/form/textarea";
    let wrapper = new Packages.com.adobe.granite.ui.components.ValueMapResourceWrapper(resource, superType);
    let wrapperProperties = wrapper.adaptTo(Packages.org.apache.sling.api.resource.ValueMap);
    wrapperProperties.putAll(properties);
    wrapperProperties.put("granite:class", "field-json-editor");
    wrapperProperties.put("fieldLabel", properties.get("cfm-element", String.class));

    let validation = properties.get("schemapath", "");
    if(!validation)
        validation = "json-schema-validator:"+validation;
    else
        validation = "json-validator";

    wrapperProperties.put("validation", validation);
    item.resource = wrapper;

    return item;
});