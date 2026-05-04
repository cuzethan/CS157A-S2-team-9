<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "My JSP App" %></title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100 flex flex-col">
  <%
    Object emailAttr = session.getAttribute("emailValue");
    boolean loggedIn = emailAttr != null && !String.valueOf(emailAttr).trim().isEmpty();
    Object admin = session.getAttribute("isAdmin");
    boolean isAdmin = admin != null && (boolean) admin;
    String displayEmail = loggedIn ? String.valueOf(emailAttr).trim() : "";
    String safeEmail = displayEmail.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    String userInitial = displayEmail.length() > 0 ? String.valueOf(displayEmail.charAt(0)).toUpperCase() : "";
    String ctx = request.getContextPath();
  %>
  <header class="relative z-40 bg-white/95 backdrop-blur shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 py-3 flex items-center justify-between">

      <a href="<%= ctx %>/" class="flex items-center gap-2">
        <img src="<%= ctx %>/assets/logo.svg" alt="SJSUMarketplace logo" class="h-9 w-9" />
        <span class="text-xl font-semibold tracking-tight text-slate-900">SJSUMarketplace</span>
      </a>

      <nav class="flex items-center gap-4 text-sm font-medium text-slate-700">
        <a href="<%= ctx %>/listings" class="hidden sm:inline-flex hover:text-blue-700 transition-colors">Listings</a>
        <% if (loggedIn) { %>
        <a href="<%= ctx %>/inbox" class="hidden sm:inline-flex hover:text-blue-700 transition-colors">Inbox</a>
        <% } %>

        <% if (!loggedIn) { %>
        <a href="<%= ctx %>/login" class="hidden sm:inline-flex rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 transition-colors">Log in</a>
        <% } else { %>
        <div class="relative" id="user-menu-root">
          <button type="button" id="user-menu-trigger"
                  class="flex items-center justify-center h-9 w-9 rounded-full bg-blue-600 text-white text-sm font-bold cursor-pointer hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-600/40 focus:ring-offset-2 transition-colors"
                  aria-expanded="false" aria-haspopup="true" title="<%= safeEmail %>">
            <%= userInitial %>
          </button>
          <div id="user-menu-panel" class="hidden absolute right-0 top-full z-50 mt-2 w-56 rounded-xl border border-slate-200 bg-white py-1 shadow-lg" role="menu">
            <div class="px-4 py-2.5 text-xs text-slate-500 truncate border-b border-slate-100" title="<%= safeEmail %>"><%= safeEmail %></div>
            <div class="py-1 px-1">
              <a href="<%= ctx %>/my-listings" role="menuitem" class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50">My Listings</a>
              <a href="<%= ctx %>/my-transactions" role="menuitem" class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50">Transactions</a>
              <a href="<%= ctx %>/favorites" role="menuitem" class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50">Favorites</a>
              <% if (isAdmin) { %>
              <a href="<%= ctx %>/admin-reports" role="menuitem" class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50">Reports</a>
              <a href="<%= ctx %>/admin" role="menuitem" class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50">Admin</a>
              <% } else { %>
              <a href="<%= ctx %>/submit-report" role="menuitem" class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50">Report</a>
              <% } %>
            </div>
            <div class="border-t border-slate-100 py-1 px-1">
              <a href="<%= ctx %>/delete-account" role="menuitem" class="block rounded-lg px-3 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50">Account Settings</a>
              <form method="post" action="<%= ctx %>/logout">
                <button type="submit" role="menuitem" class="w-full rounded-lg px-3 py-2 text-left text-sm font-medium text-red-600 hover:bg-red-50">Log out</button>
              </form>
            </div>
          </div>
        </div>
        <% } %>

        <!-- Mobile hamburger -->
        <button type="button" id="mobile-menu-trigger" class="sm:hidden inline-flex items-center justify-center h-9 w-9 rounded-lg hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-600/30 transition-colors" aria-expanded="false" aria-label="Open menu">
          <svg class="h-5 w-5 text-slate-700" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/></svg>
        </button>
      </nav>
    </div>

    <!-- Mobile menu panel -->
    <div id="mobile-menu-panel" class="hidden sm:hidden border-t border-slate-200 bg-white px-4 pb-4 pt-2">
      <div class="flex flex-col gap-1 text-sm font-medium text-slate-700">
        <a href="<%= ctx %>/listings" class="rounded-lg px-3 py-2 hover:bg-slate-50">Listings</a>
        <% if (loggedIn) { %>
        <a href="<%= ctx %>/inbox" class="rounded-lg px-3 py-2 hover:bg-slate-50">Inbox</a>
        <a href="<%= ctx %>/my-listings" class="rounded-lg px-3 py-2 hover:bg-slate-50">My Listings</a>
        <a href="<%= ctx %>/my-transactions" class="rounded-lg px-3 py-2 hover:bg-slate-50">Transactions</a>
        <a href="<%= ctx %>/favorites" class="rounded-lg px-3 py-2 hover:bg-slate-50">Favorites</a>
        <% if (isAdmin) { %>
        <a href="<%= ctx %>/admin-reports" class="rounded-lg px-3 py-2 hover:bg-slate-50">Reports</a>
        <a href="<%= ctx %>/admin" class="rounded-lg px-3 py-2 hover:bg-slate-50">Admin</a>
        <% } else { %>
        <a href="<%= ctx %>/submit-report" class="rounded-lg px-3 py-2 hover:bg-slate-50">Report</a>
        <% } %>
        <% } %>
        <% if (!loggedIn) { %>
        <a href="<%= ctx %>/login" class="rounded-lg px-3 py-2 text-blue-600 font-semibold hover:bg-blue-50">Log in</a>
        <% } %>
      </div>
    </div>
  </header>

  <script>
  (function () {
    var userRoot = document.getElementById("user-menu-root");
    if (userRoot) {
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
    }

    var mTrigger = document.getElementById("mobile-menu-trigger");
    var mPanel = document.getElementById("mobile-menu-panel");
    if (mTrigger && mPanel) {
      mTrigger.addEventListener("click", function () {
        var open = mPanel.classList.toggle("hidden");
        mTrigger.setAttribute("aria-expanded", open ? "false" : "true");
      });
    }
  })();
  </script>

  <main class="flex-1 w-full max-w-7xl mx-auto px-6 sm:px-8 py-10">
