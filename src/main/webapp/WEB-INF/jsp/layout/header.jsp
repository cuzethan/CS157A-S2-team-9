<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "My JSP App" %></title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="min-h-screen bg-slate-100">
  <header class="bg-white shadow-sm">
    <div class="max-w-5xl mx-auto px-4 py-4 flex items-center justify-between">
      <h1 class="text-xl font-semibold text-slate-800">SJSUMarketplace</h1>
      <nav class="flex gap-4 text-sm text-slate-600">
        <a href="<%= request.getContextPath() %>/" class="hover:text-blue-600">Home</a>
        <a href="<%= request.getContextPath() %>/dbtest" class="hover:text-blue-600">DB Test</a>
      </nav>
    </div>
  </header>

  <main class="max-w-5xl mx-auto px-4 py-8">
