<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  request.setAttribute("pageTitle", "Sign up - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="mx-auto w-full max-w-md bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Create account</h2>
  <p class="mt-1 text-sm text-slate-600">Join SJSUMarketplace in a few seconds.</p>

  <%
    String formError = (String) request.getAttribute("formError");
    if (formError != null) {
  %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <%
    }
    String emailValue = (String) request.getAttribute("emailValue");
    String usernameValue = (String) request.getAttribute("usernameValue");
  %>

  <div class="mt-4 rounded-xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-700">
    <p class="font-semibold text-slate-900">Requirements</p>
    <ul class="mt-2 space-y-1 list-disc pl-5">
      <li>Email must end with <span class="font-mono">@sjsu.edu</span></li>
      <li>Username: 3–20 characters, letters/numbers/underscore only</li>
      <li>Password: at least 8 characters with 1 uppercase, 1 lowercase, 1 number, and 1 symbol</li>
    </ul>
  </div>

  <form class="mt-6 space-y-4" method="post" action="<%= request.getContextPath() %>/signup">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="username">Username</label>
      <input id="username" name="username" type="text" autocomplete="username"
             value="<%= usernameValue != null ? usernameValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="email">Email</label>
      <input id="email" name="email" type="email" autocomplete="email"
             value="<%= emailValue != null ? emailValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="password">Password</label>
      <input id="password" name="password" type="password" autocomplete="new-password"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <button type="submit"
            class="w-full inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
      Sign up
    </button>

    <p class="text-center text-sm text-slate-600">
      Already have an account?
      <a class="font-semibold text-blue-700 hover:text-blue-800" href="<%= request.getContextPath() %>/login">Login</a>
    </p>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

