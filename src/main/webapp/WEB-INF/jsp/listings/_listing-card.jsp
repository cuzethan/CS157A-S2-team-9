<%-- Reusable listing card partial — expects `post` (Map) and `pic` (String) in scope --%>
<%
  String status = post.get("status");
  boolean isSold = "Sold".equalsIgnoreCase(status);
%>
<div class="flex flex-col sm:flex-row items-stretch rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden transition-shadow hover:shadow-md
            <%= isSold ? "opacity-80" : "" %>">

  <!-- Thumbnail -->
  <div class="sm:w-36 sm:min-w-[9rem] h-40 sm:h-auto flex-shrink-0 bg-slate-100 overflow-hidden">
    <% if (pic != null && !pic.isEmpty()) { %>
      <img src="<%= pic %>" alt="<%= post.get("title") %>"
           class="h-full w-full object-cover" />
    <% } else { %>
      <div class="h-full w-full flex items-center justify-center">
        <svg class="h-8 w-8 text-slate-300" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909M3.75 21h16.5A2.25 2.25 0 0022.5 18.75V5.25A2.25 2.25 0 0020.25 3H3.75A2.25 2.25 0 001.5 5.25v13.5A2.25 2.25 0 003.75 21z"/></svg>
      </div>
    <% } %>
  </div>

  <!-- Details + Actions -->
  <div class="flex-1 flex flex-col sm:flex-row sm:items-center px-5 py-4 gap-4">
    <!-- Info -->
    <div class="flex-1 min-w-0">
      <div class="flex items-center gap-2 flex-wrap">
        <p class="text-base font-bold text-slate-900 truncate <%= isSold ? "line-through decoration-slate-400" : "" %>">
          <%= post.get("title") %>
        </p>
        <span class="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold
                     <%= isSold ? "bg-amber-100 text-amber-800" : "bg-green-100 text-green-800" %>">
          <span class="h-1.5 w-1.5 rounded-full <%= isSold ? "bg-amber-500" : "bg-green-500" %>"></span>
          <%= status %>
        </span>
      </div>
      <p class="mt-1 text-lg font-semibold text-slate-800">$<%= post.get("price") %></p>
      <% if (post.get("meetupLocation") != null) { %>
        <p class="mt-0.5 text-xs text-slate-500 flex items-center gap-1">
          <svg class="h-3 w-3 text-slate-400 flex-shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1115 0z"/></svg>
          <%= post.get("meetupLocation") %>
        </p>
      <% } %>
    </div>

    <!-- Action Buttons -->
    <div class="flex items-center gap-2 sm:flex-shrink-0">
      <% if (!isSold) { %>
        <a href="<%= request.getContextPath() %>/edit-listing?id=<%= post.get("id") %>"
           class="inline-flex items-center justify-center gap-1.5 rounded-lg border border-slate-300 bg-white min-w-[6.5rem] px-3.5 py-2 text-xs font-semibold text-slate-700 shadow-sm hover:bg-slate-50 transition-colors">
          <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931z"/></svg>
          Edit
        </a>
        <form method="post" action="<%= request.getContextPath() %>/my-listings">
          <input type="hidden" name="action" value="mark_sold" />
          <input type="hidden" name="postId" value="<%= post.get("id") %>" />
          <button type="submit"
                  class="inline-flex items-center justify-center gap-1.5 rounded-lg border border-amber-300 text-amber-700 bg-white hover:bg-amber-50 min-w-[6.5rem] px-3.5 py-2 text-xs font-semibold shadow-sm transition-colors">
            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            Mark Sold
          </button>
        </form>
        <form method="post" action="<%= request.getContextPath() %>/my-listings"
              onsubmit="return confirm('Are you sure you want to delete this listing? This cannot be undone.');">
          <input type="hidden" name="action" value="delete" />
          <input type="hidden" name="postId" value="<%= post.get("id") %>" />
          <button type="submit"
                  class="inline-flex items-center justify-center gap-1.5 rounded-lg border border-red-200 bg-white min-w-[6.5rem] px-3.5 py-2 text-xs font-semibold text-red-600 shadow-sm hover:bg-red-50 transition-colors">
            <svg class="h-3.5 w-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"/></svg>
            Delete
          </button>
        </form>
      <% } %>
    </div>
  </div>
</div>
