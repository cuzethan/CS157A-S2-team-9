<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "My JSP App" %></title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 flex flex-col">
  <header class="bg-white/95 backdrop-blur shadow-sm">
    <div class="max-w-7xl mx-auto px-6 sm:px-8 py-5 flex items-center justify-between">
      <a href="<%= request.getContextPath() %>/" class="flex items-center gap-3">
        <img
          src="<%= request.getContextPath() %>/assets/logo.svg"
          alt="SJSUMarketplace logo"
          class="h-11 w-11"
        />
        <span class="text-2xl font-semibold tracking-tight text-slate-900">SJSUMarketplace</span>
      </a>
      <nav class="flex items-center gap-6 text-base font-medium text-slate-700">
        <%
          Object emailAttr = session.getAttribute("emailValue");
          boolean loggedIn = emailAttr != null && !String.valueOf(emailAttr).trim().isEmpty();
          Object admin = session.getAttribute("isAdmin");
          boolean isAdmin = admin != null && (boolean) admin;
        %>
        <% if (loggedIn) { %>
		<a href="<%= request.getContextPath() %>/my-transactions" class="hover:text-blue-700">Transactions</a>
		<% } %>
        <% if (loggedIn && isAdmin) { %>
		<a href="<%= request.getContextPath() %>/admin-reports" class="hover:text-blue-700">Reports</a>
		<% } %>
		<% if (loggedIn && !isAdmin) { %>
		<a href="<%= request.getContextPath() %>/submit-report" class="hover:text-blue-700">Report</a>
		<% } %>
        <% if (loggedIn) { %>
		<a href="<%= request.getContextPath() %>/inbox" class="hover:text-blue-700">Inbox</a>
		<% } %>
        <% if (loggedIn && isAdmin) { %>
        <a href="<%= request.getContextPath() %>/admin" class="hover:text-blue-700">Admin</a>
        <% } %>
        <a href="<%= request.getContextPath() %>/listings" class="hover:text-blue-700">Listings</a>
        <% if (loggedIn) { %>
        <a href="<%= request.getContextPath() %>/my-listings" class="hover:text-blue-700">My Listings</a>
        <% } %>
        <% if (!loggedIn) { %>
        <a href="<%= request.getContextPath() %>/login" class="hover:text-blue-700">Login</a>
        <% } else {
          String displayEmail = String.valueOf(emailAttr).trim();
          String safeEmail = displayEmail.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
          String ctx = request.getContextPath();
        %>
        <div class="relative" id="user-menu-root">
          <button type="button" id="user-menu-trigger"
                  class="text-left text-slate-600 max-w-[14rem] truncate cursor-pointer rounded-lg px-2 py-1 -mx-2 -my-1 hover:bg-slate-100 hover:text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-600/30"
                  aria-expanded="false" aria-haspopup="true" title="<%= safeEmail %>">
            <%= safeEmail %>
          </button>
          <div id="user-menu-panel" class="hidden absolute right-0 top-full z-50 mt-2 w-56 rounded-xl border border-slate-200 bg-white py-1 shadow-lg" role="menu">
            <div class="border-b border-slate-100 px-4 py-2 text-xs text-slate-500 truncate" title="<%= safeEmail %>"><%= safeEmail %></div>
            <form method="post" action="<%= ctx %>/logout" class="px-1 py-1">
            <a href="<%= ctx %>/delete-account" role="menuitem"
   				class="block rounded-lg px-3 py-2 text-left text-sm font-medium text-slate-700 hover:bg-slate-50 mx-1">
  				Account Settings
			</a>
              <button type="submit" role="menuitem"
                      class="w-full rounded-lg px-3 py-2 text-left text-sm font-medium text-red-700 hover:bg-red-50">
                Log out
              </button>
            </form>
          </div>
        </div>
        <script>
        (function () {
          var root = document.getElementById("user-menu-root");
          if (!root) return;
          var trigger = document.getElementById("user-menu-trigger");
          var panel = document.getElementById("user-menu-panel");
          function openMenu(open) {
            panel.classList.toggle("hidden", !open);
            trigger.setAttribute("aria-expanded", open ? "true" : "false");
          }
          trigger.addEventListener("click", function (e) {
            e.stopPropagation();
            openMenu(panel.classList.contains("hidden"));
          });
          document.addEventListener("click", function () { openMenu(false); });
          panel.addEventListener("click", function (e) { e.stopPropagation(); });
          document.addEventListener("keydown", function (e) {
            if (e.key === "Escape") openMenu(false);
          });
        })();
        </script>
        <% } %>
      </nav>
    </div>
  </header>

  <main class="flex-1 w-full max-w-7xl mx-auto px-6 sm:px-8 py-10">
