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
    <div class="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6">
      <% for (Map<String, String> post : posts) {
           String pic = post.get("picture");
      %>
        <div class="group cursor-pointer">
          <div class="aspect-square overflow-hidden rounded-lg bg-slate-100">
            <% if (pic != null && !pic.isEmpty()) { %>
              <img src="<%= pic %>" alt="<%= post.get("title") %>"
                   class="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
            <% } else { %>
              <div class="h-full w-full flex items-center justify-center">
                <span class="text-slate-400 text-xs">No image</span>
              </div>
            <% } %>
          </div>
          <div class="mt-2 px-0.5">
            <p class="text-sm font-bold text-slate-900">$<%= post.get("price") %></p>
            <p class="text-[13px] font-normal text-slate-800 line-clamp-2 leading-tight h-9 mt-0.5"><%= post.get("title") %></p>
            <p class="text-[12px] text-slate-500 truncate mt-1">
              <%= post.get("meetupLocation") != null ? post.get("meetupLocation") : "" %>
            </p>
          </div>
        </div>
      <% } %>
    </div>
  <% } %>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
