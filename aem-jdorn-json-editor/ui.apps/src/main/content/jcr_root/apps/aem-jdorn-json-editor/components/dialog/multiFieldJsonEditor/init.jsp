
<%--
  ADOBE CONFIDENTIAL
  ___________________

  Copyright 2015 Adobe
  All Rights Reserved.

  NOTICE: All information contained herein is, and remains
  the property of Adobe and its suppliers, if any. The intellectual
  and technical concepts contained herein are proprietary to Adobe
  and its suppliers and are protected by all applicable intellectual
  property laws, including trade secret and copyright laws.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe.
--%><%
%><%@ include file="/libs/granite/ui/global.jsp" %><%
%><%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%><%
%><%@ page session="false"
          import="java.util.Calendar,
                  java.util.HashMap,
                  org.apache.jackrabbit.util.ISO8601,
                  org.apache.sling.api.wrappers.ValueMapDecorator,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.Field" %><%

    Config cfg = cmp.getConfig();

    // Calendar formatting is done by FormData
    String value = cmp.getValue().val(cmp.getExpressionHelper().getString(cfg.get("value", "")));
    String values[] = cmp.getValue().val(new String[]{});
    //out.println("1"+values.length);
    //out.println("11"+values[1]);
    //out.println(cmp.getValue().get("value"));
    //out.println(cmp.getValue().get("value"));

    ValueMap vm = new ValueMapDecorator(new HashMap<String, Object>());
    vm.put("value", value);
    vm.put("values", values);
    request.setAttribute("multiFieldValues", values);

    request.setAttribute(Field.class.getName(), vm);
%>