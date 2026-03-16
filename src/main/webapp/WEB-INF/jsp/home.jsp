<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  request.setAttribute("pageTitle", "SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="bg-white rounded-xl shadow-sm p-8">
  <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
    <div>
      <p class="text-sm font-semibold text-blue-700">San José State University</p>
      <h2 class="mt-2 text-3xl font-bold tracking-tight text-slate-900">
        Buy &amp; sell with other Spartans
      </h2>
      <p class="mt-3 max-w-2xl text-slate-600">
        Simple starter homepage for your JSP app. Add categories, listings, search, and auth links here.
      </p>
    </div>

    <div class="flex flex-wrap gap-3">
      <a href="<%= request.getContextPath() %>/dbtest"
         class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">
        DB Test
      </a>
      <a href="#"
         class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50">
        Browse listings
      </a>
    </div>
  </div>
</div>

<div class="mt-6 grid gap-4 md:grid-cols-3">
  <div class="bg-white rounded-xl shadow-sm p-6">
    <h3 class="text-sm font-semibold text-slate-900">Feature 1</h3>
    <p class="mt-2 text-sm text-slate-600">Add a listings table/grid and filters.</p>
  </div>
  <div class="bg-white rounded-xl shadow-sm p-6">
    <h3 class="text-sm font-semibold text-slate-900">Feature 2</h3>
    <p class="mt-2 text-sm text-slate-600">Add login/register and user profiles.</p>
  </div>
  <div class="bg-white rounded-xl shadow-sm p-6">
    <h3 class="text-sm font-semibold text-slate-900">Feature 3</h3>
    <p class="mt-2 text-sm text-slate-600">Add create listing, messages, and checkout flow.</p>
  </div>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

