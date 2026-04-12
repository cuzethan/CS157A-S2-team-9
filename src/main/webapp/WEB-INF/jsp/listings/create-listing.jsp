<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
  request.setAttribute("pageTitle", "Create Listing - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<%
  String formError = (String) request.getAttribute("formError");
  String formSuccess = (String) request.getAttribute("formSuccess");

  String titleValue = (String) request.getAttribute("titleValue");
  String priceValue = (String) request.getAttribute("priceValue");
  String descriptionValue = (String) request.getAttribute("descriptionValue");
  String pictureValue = (String) request.getAttribute("pictureValue");
  String locationValue = (String) request.getAttribute("locationValue");
  String meetupValue = (String) request.getAttribute("meetupValue");

  List<Map<String, String>> meetupLocations =
      (List<Map<String, String>>) request.getAttribute("meetupLocations");
%>

<div class="mx-auto w-full max-w-lg bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Create Listing</h2>
  <p class="mt-1 text-sm text-slate-600">Post an item for sale to the SJSU community.</p>

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

  <form class="mt-6 space-y-4" method="post" action="<%= request.getContextPath() %>/create-listing">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="title">Item Title <span class="text-red-500">*</span></label>
      <input id="title" name="title" type="text" required
             value="<%= titleValue != null ? titleValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="price">Price ($) <span class="text-red-500">*</span></label>
      <input id="price" name="price" type="number" step="0.01" min="0.01" required
             value="<%= priceValue != null ? priceValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="description">Description <span class="text-red-500">*</span></label>
      <textarea id="description" name="description" rows="4" required
                class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20"><%= descriptionValue != null ? descriptionValue : "" %></textarea>
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="meetupId">Meetup Location <span class="text-red-500">*</span></label>
      <select id="meetupId" name="meetupId" required
              class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20">
        <option value="">Select a location</option>
        <% if (meetupLocations != null) {
             for (Map<String, String> loc : meetupLocations) {
               String selected = loc.get("id").equals(meetupValue) ? "selected" : "";
        %>
          <option value="<%= loc.get("id") %>" <%= selected %>><%= loc.get("name") %></option>
        <%   }
           }
        %>
      </select>
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="locationDetails">Location Details (specific spot, room #, etc.)</label>
      <input id="locationDetails" name="locationDetails" type="text"
             value="<%= locationValue != null ? locationValue : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>
    <div>
      <label class="block text-sm font-medium text-slate-700" for="pictureFile">Picture</label>
      <input id="pictureFile" type="file" accept="image/*"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm file:mr-3 file:rounded-md file:border-0 file:bg-blue-50 file:px-3 file:py-1 file:text-sm file:font-semibold file:text-blue-700 hover:file:bg-blue-100 focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
      <input id="picture" name="picture" type="hidden"
             value="<%= pictureValue != null ? pictureValue : "" %>" />
      <p id="pictureError" class="mt-1 text-sm text-red-600 hidden"></p>
      <img id="picturePreview" src="<%= pictureValue != null ? pictureValue : "" %>"
           alt="Preview"
           class="mt-2 h-32 w-32 rounded-lg object-cover border border-slate-200 <%= pictureValue != null ? "" : "hidden" %>" />
    </div>

    <script>
      document.getElementById('pictureFile').addEventListener('change', function(e) {
        var file = e.target.files[0];
        var hidden = document.getElementById('picture');
        var preview = document.getElementById('picturePreview');
        var error = document.getElementById('pictureError');
        error.classList.add('hidden');

        if (!file) {
          hidden.value = '';
          preview.classList.add('hidden');
          return;
        }

        if (file.size > 2 * 1024 * 1024) {
          error.textContent = 'Image must be under 2 MB.';
          error.classList.remove('hidden');
          e.target.value = '';
          hidden.value = '';
          preview.classList.add('hidden');
          return;
        }

        var reader = new FileReader();
        reader.onload = function(ev) {
          hidden.value = ev.target.result;
          preview.src = ev.target.result;
          preview.classList.remove('hidden');
        };
        reader.readAsDataURL(file);
      });
    </script>

    <button type="submit"
            class="w-full inline-flex items-center justify-center rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
      Post Listing
    </button>

    <p class="text-center text-sm text-slate-600">
      <a class="font-semibold text-blue-700 hover:text-blue-800" href="<%= request.getContextPath() %>/listings">&larr; Back to Listings</a>
    </p>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>
