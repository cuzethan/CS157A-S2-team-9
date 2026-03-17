<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  request.setAttribute("pageTitle", "Listings - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="bg-white rounded-2xl shadow-sm p-8">
  <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
    <div>
      <h2 class="text-2xl font-bold tracking-tight text-slate-900">Listings</h2>
      <p class="mt-1 text-sm text-slate-600">Browse items posted by students.</p>
    </div>
    <a href="#"
       class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">
      Create listing
    </a>
  </div>

  <div class="mt-8 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
    <p class="text-sm font-semibold text-slate-900">Work in progress</p>
    <p class="mt-2 text-sm text-slate-600">
      This page will show a grid of listings, categories, filters, and search.
    </p>
  </div>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

