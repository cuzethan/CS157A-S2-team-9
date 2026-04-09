<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
  request.setAttribute("pageTitle", "Listings - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<%
  List<Map<String, String>> posts =
      (List<Map<String, String>>) request.getAttribute("posts");
%>

<div class="bg-white rounded-2xl shadow-sm p-8">
  <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
    <div>
      <h2 class="text-2xl font-bold tracking-tight text-slate-900">Listings</h2>
      <p class="mt-1 text-sm text-slate-600">Browse items posted by students.</p>
    </div>
    <a href="<%= request.getContextPath() %>/create-listing"
       class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">
      Create listing
    </a>
  </div>

  <% if (posts == null || posts.isEmpty()) { %>
    <div class="mt-8 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
      <p class="text-sm font-semibold text-slate-900">No listings yet</p>
      <p class="mt-2 text-sm text-slate-600">
        Be the first to post an item for sale!
      </p>
    </div>
  <% } else { %>
    <div class="mt-8 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
      <% for (Map<String, String> post : posts) {
           String pic = post.get("picture");
           String desc = post.get("description");
           if (desc != null && desc.length() > 100) {
             desc = desc.substring(0, 100) + "...";
           }
      %>
        <div class="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden flex flex-col">
          <% if (pic != null && !pic.isEmpty()) { %>
            <img src="<%= pic %>" alt="<%= post.get("title") %>"
                 class="h-40 w-full object-cover" />
          <% } else { %>
            <div class="h-40 w-full bg-slate-100 flex items-center justify-center">
              <span class="text-slate-400 text-sm">No image</span>
            </div>
          <% } %>
          <div class="p-4 flex flex-col flex-1">
            <h3 class="text-base font-semibold text-slate-900 truncate"><%= post.get("title") %></h3>
            <p class="mt-1 text-lg font-bold text-blue-600">$<%= post.get("price") %></p>
            <p class="mt-2 text-sm text-slate-600 flex-1"><%= desc %></p>
            <div class="mt-3 flex items-center gap-1 text-xs text-slate-500">
              <svg class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.828 0l-4.243-4.243a8 8 0 1111.314 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              <%= post.get("meetupLocation") != null ? post.get("meetupLocation") : "—" %>
            </div>
          </div>
        </div>
      <% } %>
    </div>
  <% } %>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
