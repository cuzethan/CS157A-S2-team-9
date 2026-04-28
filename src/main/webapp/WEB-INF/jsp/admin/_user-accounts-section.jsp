<%-- User-account management section with sortable columns and quick search. --%>
<section class="bg-white rounded-2xl shadow-sm p-8">
  <div class="flex items-center justify-between">
    <h3 class="text-xl font-semibold text-slate-900">Manage User Accounts</h3>
    <span class="rounded-lg bg-slate-100 px-3 py-1 text-sm font-medium text-slate-700">
      <%= users.size() %> users
    </span>
  </div>
  <div class="mt-4">
    <label for="userSearch" class="sr-only">Search users</label>
    <input
      id="userSearch"
      type="search"
      placeholder="Search by email or username"
      class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-800 placeholder:text-slate-400 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200"
    />
  </div>

  <% if (formError != null) { %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <% } %>

  <% if (formSuccess != null) { %>
    <div class="mt-4 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
      <%= formSuccess %>
    </div>
  <% } %>

  <div class="mt-6 overflow-hidden rounded-xl border border-slate-200">
    <div class="grid grid-cols-5 gap-4 border-b border-slate-200 bg-slate-50 px-4 py-3 text-xs font-semibold uppercase tracking-wide text-slate-600">
      <div>
        <a href="<%= request.getContextPath() %>/admin<%= "email".equals(sort) ? ("asc".equals(dir) ? "?sort=email&dir=desc" : ("desc".equals(dir) ? "" : "?sort=email&dir=asc")) : "?sort=email&dir=asc" %>"
           class="inline-flex items-center gap-1 hover:text-slate-900">
          Email
          <%= "email".equals(sort) ? ("asc".equals(dir) ? "&uarr;" : "&darr;") : "" %>
        </a>
      </div>
      <div>
        <a href="<%= request.getContextPath() %>/admin<%= "username".equals(sort) ? ("asc".equals(dir) ? "?sort=username&dir=desc" : ("desc".equals(dir) ? "" : "?sort=username&dir=asc")) : "?sort=username&dir=asc" %>"
           class="inline-flex items-center gap-1 hover:text-slate-900">
          Username
          <%= "username".equals(sort) ? ("asc".equals(dir) ? "&uarr;" : "&darr;") : "" %>
        </a>
      </div>
      <div>
        <a href="<%= request.getContextPath() %>/admin<%= "hasposts".equals(sort) ? ("asc".equals(dir) ? "?sort=hasPosts&dir=desc" : ("desc".equals(dir) ? "" : "?sort=hasPosts&dir=asc")) : "?sort=hasPosts&dir=asc" %>"
           class="inline-flex items-center gap-1 hover:text-slate-900">
          Has Posts
          <%= "hasposts".equals(sort) ? ("asc".equals(dir) ? "&uarr;" : "&darr;") : "" %>
        </a>
      </div>
      <div>
        <a href="<%= request.getContextPath() %>/admin<%= "isadmin".equals(sort) ? ("asc".equals(dir) ? "?sort=isAdmin&dir=desc" : ("desc".equals(dir) ? "" : "?sort=isAdmin&dir=asc")) : "?sort=isAdmin&dir=asc" %>"
           class="inline-flex items-center gap-1 hover:text-slate-900">
          Is Admin
          <%= "isadmin".equals(sort) ? ("asc".equals(dir) ? "&uarr;" : "&darr;") : "" %>
        </a>
      </div>
      <div>Action</div>
    </div>

    <div class="max-h-[520px] overflow-y-auto divide-y divide-slate-100">
      <% if (users.isEmpty()) { %>
        <div class="px-4 py-10 text-center text-sm text-slate-600">No users found.</div>
      <% } else { %>
        <% for (Map<String, Object> user : users) {
             String email = (String) user.get("email");
             String username = (String) user.get("username");
             boolean hasPosts = Boolean.TRUE.equals(user.get("hasPosts"));
             boolean isAdminUser = Boolean.TRUE.equals(user.get("isAdmin"));
             boolean isCurrentAccount = currentAdminEmail != null && currentAdminEmail.equalsIgnoreCase(email);
             boolean isSelected = selectedUser != null && selectedUser.equalsIgnoreCase(email);
             String selectedHref = request.getContextPath() + "/admin?selectedUser="
                 + URLEncoder.encode(email, StandardCharsets.UTF_8) + sortParams;
        %>
          <div class="user-row grid grid-cols-5 items-center gap-4 px-4 py-3 text-sm <%= isSelected ? "bg-indigo-50" : "" %>"
               data-email="<%= email.toLowerCase() %>"
               data-username="<%= username.toLowerCase() %>">
            <div class="truncate">
              <a href="<%= selectedHref %>" class="text-slate-800 hover:text-indigo-700 hover:underline"><%= email %></a>
            </div>
            <div class="truncate">
              <a href="<%= selectedHref %>" class="font-medium text-slate-900 hover:text-indigo-700 hover:underline"><%= username %></a>
            </div>
            <div class="<%= hasPosts ? "text-emerald-600" : "text-slate-400" %>"><%= hasPosts ? "&#10003;" : "&mdash;" %></div>
            <div class="<%= isAdminUser ? "text-indigo-600" : "text-slate-400" %>"><%= isAdminUser ? "&#10003;" : "&mdash;" %></div>
            <div>
              <% if (isCurrentAccount) { %>
                <button type="button" disabled
                        class="inline-flex cursor-not-allowed items-center justify-center rounded-lg border border-slate-200 bg-slate-100 px-3 py-1.5 text-xs font-semibold text-slate-400">
                  Current account
                </button>
              <% } else if (isAdminUser) { %>
                <button type="button" disabled
                        class="inline-flex cursor-not-allowed items-center justify-center rounded-lg border border-slate-200 bg-slate-100 px-3 py-1.5 text-xs font-semibold text-slate-400">
                  Admin protected
                </button>
              <% } else { %>
                <form method="post" action="<%= request.getContextPath() %>/admin" class="inline">
                  <input type="hidden" name="action" value="deleteUser" />
                  <input type="hidden" name="targetEmail" value="<%= email %>" />
                  <button type="submit"
                          class="inline-flex items-center justify-center rounded-lg border border-red-200 bg-red-50 px-3 py-1.5 text-xs font-semibold text-red-700 hover:bg-red-100">
                    Delete
                  </button>
                </form>
              <% } %>
            </div>
          </div>
        <% } %>
      <% } %>
    </div>
  </div>

  <%-- This inline workspace appears only after an admin clicks a user row. --%>
  <% if (selectedUser != null) { %>
    <%@ include file="/WEB-INF/jsp/admin/_user-post-workspace.jsp" %>
  <% } %>
</section>
