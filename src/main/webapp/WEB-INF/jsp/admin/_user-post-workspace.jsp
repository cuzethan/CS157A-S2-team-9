<%-- Workspace for editing/deleting posts owned by the selected user. --%>
<div class="mt-8 rounded-2xl border border-indigo-100 bg-indigo-50/40 p-6">
  <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
    <div>
      <h4 class="text-lg font-semibold text-slate-900">Manage Selected User Posts</h4>
      <p class="text-sm text-slate-600">
        Managing posts for <span class="font-semibold text-slate-800"><%= selectedUserName %></span>
        (<span class="font-mono text-xs"><%= selectedUser %></span>)
      </p>
    </div>
    <a href="<%= request.getContextPath() %>/admin<%= (sort != null && dir != null) ? ("?sort=" + sort + "&dir=" + dir) : "" %>"
       class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-3 py-2 text-xs font-semibold text-slate-700 hover:bg-slate-50">
      Close workspace
    </a>
  </div>

  <% if (postFormError != null) { %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= postFormError %>
    </div>
  <% } %>

  <% if (postFormSuccess != null) { %>
    <div class="mt-4 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
      <%= postFormSuccess %>
    </div>
  <% } %>

  <% if (selectedUserPosts.isEmpty()) { %>
    <div class="mt-5 rounded-xl border border-dashed border-slate-300 bg-white p-8 text-center text-sm text-slate-600">
      This user has no posts yet.
    </div>
  <% } else { %>
    <div class="mt-5 space-y-4">
      <% for (Map<String, String> post : selectedUserPosts) {
           String postId = post.get("id");
           String title = post.get("title");
           String price = post.get("price");
           String description = post.get("description");
           String picture = post.get("picture");
           String locationDetails = post.get("locationDetails");
           String meetupId = post.get("meetupId");
           String status = post.get("status");
      %>
        <%-- Each post expands to reveal an inline admin edit form. --%>
        <details class="rounded-xl border border-slate-200 bg-white p-4">
          <summary class="cursor-pointer list-none">
            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p class="text-sm font-semibold text-slate-900"><%= title %></p>
                <p class="text-xs text-slate-500">Post #<%= postId %> &middot; <%= post.get("meetupLocation") %></p>
              </div>
              <div class="text-sm font-semibold text-slate-800">$<%= price %></div>
            </div>
          </summary>

          <form method="post" action="<%= request.getContextPath() %>/admin" class="mt-4 grid grid-cols-1 gap-3 md:grid-cols-2">
            <input type="hidden" name="action" value="adminUpdatePost" />
            <input type="hidden" name="targetEmail" value="<%= selectedUser %>" />
            <input type="hidden" name="postId" value="<%= postId %>" />

            <label class="text-sm text-slate-700">
              Title
              <input name="title" type="text" required maxlength="45" value="<%= title != null ? title : "" %>"
                     class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200" />
            </label>

            <label class="text-sm text-slate-700">
              Price
              <input name="price" type="number" step="0.01" min="0.01" required value="<%= price != null ? price : "" %>"
                     class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200" />
            </label>

            <label class="text-sm text-slate-700 md:col-span-2">
              Description
              <textarea name="description" rows="3" required
                        class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200"><%= description != null ? description : "" %></textarea>
            </label>

            <label class="text-sm text-slate-700">
              Meetup Location
              <select name="meetupId" required
                      class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200">
                <option value="">Select a location</option>
                <% for (Map<String, String> loc : meetupLocations) {
                     String selected = loc.get("id").equals(meetupId) ? "selected" : "";
                %>
                  <option value="<%= loc.get("id") %>" <%= selected %>><%= loc.get("name") %></option>
                <% } %>
              </select>
            </label>

            <label class="text-sm text-slate-700">
              Status
              <select name="status" required
                      class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200">
                <option value="Available" <%= "Available".equalsIgnoreCase(status) ? "selected" : "" %>>Available</option>
                <option value="Sold" <%= "Sold".equalsIgnoreCase(status) ? "selected" : "" %>>Sold</option>
              </select>
            </label>

            <label class="text-sm text-slate-700 md:col-span-2">
              Location Details
              <input name="locationDetails" type="text" value="<%= locationDetails != null ? locationDetails : "" %>"
                     class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200" />
            </label>

            <label class="text-sm text-slate-700 md:col-span-2">
              Picture (URL or base64)
              <input name="picture" type="text" value="<%= picture != null ? picture : "" %>"
                     class="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-200" />
            </label>

            <div class="md:col-span-2">
              <button type="submit"
                      class="inline-flex items-center justify-center rounded-lg bg-indigo-600 px-4 py-2 text-xs font-semibold text-white hover:bg-indigo-700">
                Save Post Changes
              </button>
            </div>
          </form>
          <form method="post" action="<%= request.getContextPath() %>/admin"
                class="mt-2"
                onsubmit="return confirm('Delete this post? This cannot be undone.');">
            <input type="hidden" name="action" value="adminDeletePost" />
            <input type="hidden" name="targetEmail" value="<%= selectedUser %>" />
            <input type="hidden" name="postId" value="<%= postId %>" />
            <button type="submit"
                    class="inline-flex items-center justify-center rounded-lg border border-red-200 bg-red-50 px-4 py-2 text-xs font-semibold text-red-700 hover:bg-red-100">
              Delete Post
            </button>
          </form>
        </details>
      <% } %>
    </div>
  <% } %>
</div>
