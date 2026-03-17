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
      <nav class="flex gap-6 text-base font-medium text-slate-700">
        <a href="<%= request.getContextPath() %>/" class="hover:text-blue-700">Home</a>
        <a href="<%= request.getContextPath() %>/listings" class="hover:text-blue-700">Listings</a>
        <a href="<%= request.getContextPath() %>/dbtest" class="hover:text-blue-700">DB Test</a>
        <a href="<%= request.getContextPath() %>/login" class="hover:text-blue-700">Login</a>
      </nav>
    </div>
  </header>

  <main class="flex-1 w-full max-w-7xl mx-auto px-6 sm:px-8 py-10">
