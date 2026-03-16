<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setAttribute("pageTitle", "Database Test");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="bg-white rounded-xl shadow-sm p-6 mb-6">
  <h2 class="text-lg font-semibold text-slate-800 mb-4">
    3-Tier Architecture &mdash; JDBC Connection Example
  </h2>

  <p class="text-sm text-slate-600 mb-4">
    This page checks whether the app can connect to the database and list entries from the
    <span class="font-mono">Student</span> table.
  </p>

  <%
      Boolean statusOk = (Boolean) request.getAttribute("statusOk");
      String statusMessage = (String) request.getAttribute("statusMessage");
      if (statusMessage != null) {
  %>
    <div class="mb-4 text-sm <%= Boolean.TRUE.equals(statusOk) ? "text-green-700" : "text-red-700" %>">
      <%= statusMessage %>
    </div>
  <%
      }
  %>

  <div class="overflow-x-auto rounded-lg border border-slate-200">
    <table class="min-w-full divide-y divide-slate-200 text-sm">
      <thead class="bg-slate-50">
        <tr>
          <th class="px-3 py-2 text-left font-medium text-slate-600">SJSU ID</th>
          <th class="px-3 py-2 text-left font-medium text-slate-600">Name</th>
          <th class="px-3 py-2 text-left font-medium text-slate-600">Major</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-slate-100">
        <%
            String tableRowsHtml = (String) request.getAttribute("tableRowsHtml");
            if (tableRowsHtml != null) {
                out.print(tableRowsHtml);
            }
        %>
      </tbody>
    </table>
  </div>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

