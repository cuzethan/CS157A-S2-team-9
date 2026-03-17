<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  request.setAttribute("pageTitle", "Login - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="mx-auto w-full max-w-md bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Login</h2>
  <p class="mt-1 text-sm text-slate-600">Welcome back. Sign in to continue.</p>

  <form class="mt-6 space-y-4" method="post" action="#">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="email">Email</label>
      <input id="email" name="email" type="email" autocomplete="email"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="password">Password</label>
      <input id="password" name="password" type="password" autocomplete="current-password"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <button type="submit"
            class="w-full inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
      Sign in
    </button>

    <p class="text-center text-sm text-slate-600">
      Don’t have an account?
      <a class="font-semibold text-blue-700 hover:text-blue-800" href="<%= request.getContextPath() %>/signup">Sign up</a>
    </p>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

