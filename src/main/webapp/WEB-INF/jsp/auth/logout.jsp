<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  javax.servlet.http.HttpSession sess = request.getSession(false);
  if (sess != null) {
    sess.invalidate();
  }
  response.sendRedirect(request.getContextPath() + "/");
%>
