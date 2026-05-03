<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // Route: if ?with= is present, show conversation; otherwise inbox.
  String withParam = request.getParameter("with");
  if (withParam != null && !withParam.trim().isEmpty()) {
%>
<%@ include file="/WEB-INF/jsp/messages/conversation.jsp" %>
<%
  } else {
%>
<%@ include file="/WEB-INF/jsp/messages/inbox.jsp" %>
<%
  }
%>