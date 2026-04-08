<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  request.setAttribute("pageTitle", "Admin - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="space-y-6">
  <section class="bg-white rounded-2xl shadow-sm p-8">
    <h2 class="text-3xl font-bold tracking-tight text-slate-900">Admin Dashboard</h2>
    <p class="mt-2 text-sm text-slate-600">
      Starter template for administrator features. Add your modules below.
    </p>
  </section>

  <section class="grid gap-4 md:grid-cols-3">
    <div class="bg-white rounded-xl shadow-sm p-6">
      <h3 class="text-lg font-semibold text-slate-900">Users</h3>
      <p class="mt-2 text-sm text-slate-600">Placeholder for user management tools.</p>
    </div>
    <div class="bg-white rounded-xl shadow-sm p-6">
      <h3 class="text-lg font-semibold text-slate-900">Listings</h3>
      <p class="mt-2 text-sm text-slate-600">Placeholder for listing moderation and approvals.</p>
    </div>
    <div class="bg-white rounded-xl shadow-sm p-6">
      <h3 class="text-lg font-semibold text-slate-900">Reports</h3>
      <p class="mt-2 text-sm text-slate-600">Placeholder for flagged content and activity logs.</p>
    </div>
  </section>

  <section class="bg-white rounded-2xl shadow-sm p-8">
    <h3 class="text-xl font-semibold text-slate-900">Work Area</h3>
    <div class="mt-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
      <p class="text-sm font-medium text-slate-700">
        Add admin forms, tables, or controls here.
      </p>
    </div>
  </section>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

