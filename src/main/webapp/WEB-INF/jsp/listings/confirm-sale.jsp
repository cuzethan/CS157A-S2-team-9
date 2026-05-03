<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%!
private static String trimToNull(String value) {
    if (value == null) return null;
    String trimmed = value.trim();
    return trimmed.isEmpty() ? null : trimmed;
}
%>
<%
javax.servlet.http.HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("emailValue") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
String sellerEmail = (String) userSession.getAttribute("emailValue");
String postIdStr   = trimToNull(request.getParameter("id"));

if (postIdStr == null) {
    response.sendRedirect(request.getContextPath() + "/my-listings");
    return;
}

int postId;
try {
    postId = Integer.parseInt(postIdStr);
} catch (NumberFormatException e) {
    response.sendRedirect(request.getContextPath() + "/my-listings");
    return;
}

// Load the listing to confirm ownership and get price
String listingTitle = null;
BigDecimal listingPrice = null;
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(
         "SELECT title, price FROM Posts WHERE post_ID = ? AND email = ? AND item_status = 'Available'")) {
    ps.setInt(1, postId);
    ps.setString(2, sellerEmail);
    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            listingTitle  = rs.getString("title");
            listingPrice  = rs.getBigDecimal("price");
        } else {
            response.sendRedirect(request.getContextPath() + "/my-listings");
            return;
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/my-listings");
    return;
}

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String buyerEmail = trimToNull(request.getParameter("buyerEmail"));
    String salePriceStr = trimToNull(request.getParameter("salePrice"));

    if (buyerEmail == null) {
        request.setAttribute("formError", "Buyer email is required.");
    } else if (buyerEmail.equalsIgnoreCase(sellerEmail)) {
        request.setAttribute("formError", "Buyer and seller cannot be the same account.");
    } else if (salePriceStr == null) {
        request.setAttribute("formError", "Sale price is required.");
    } else {
        // Verify buyer exists
        boolean buyerExists = false;
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT email FROM Users WHERE email = ?")) {
            ps.setString(1, buyerEmail);
            try (ResultSet rs = ps.executeQuery()) {
                buyerExists = rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (!buyerExists) {
            request.setAttribute("formError", "No account found with that email address.");
        } else {
            BigDecimal salePrice;
            try {
                salePrice = new BigDecimal(salePriceStr);
                if (salePrice.compareTo(BigDecimal.ZERO) <= 0)
                    throw new NumberFormatException();
            } catch (NumberFormatException e) {
                request.setAttribute("formError", "Sale price must be a positive number.");
                salePrice = null;
            }

            if (salePrice != null && request.getAttribute("formError") == null) {
                Connection con = null;
                try {
                    con = Database.getConnection();
                    con.setAutoCommit(false);

                    // Mark post as Sold
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE Posts SET item_status = 'Sold' WHERE post_ID = ? AND email = ?")) {
                        ps.setInt(1, postId);
                        ps.setString(2, sellerEmail);
                        ps.executeUpdate();
                    }

                    // Record transaction
                    try (PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO Transactions (sale_price, buyer_email, seller_email, post_ID) "
                          + "VALUES (?, ?, ?, ?)")) {
                        ps.setBigDecimal(1, salePrice);
                        ps.setString(2, buyerEmail);
                        ps.setString(3, sellerEmail);
                        ps.setInt(4, postId);
                        ps.executeUpdate();
                    }

                    con.commit();
                    response.sendRedirect(request.getContextPath() + "/my-listings?sold=1");
                    return;
                } catch (SQLException e) {
                    if (con != null) { try { con.rollback(); } catch (SQLException ignored) {} }
                    e.printStackTrace();
                    request.setAttribute("formError", "Database error. Please try again.");
                } finally {
                    if (con != null) {
                        try { con.setAutoCommit(true); } catch (SQLException ignored) {}
                        try { con.close(); } catch (SQLException ignored) {}
                    }
                }
            }
        }
    }
    request.setAttribute("buyerEmailValue", buyerEmail);
    request.setAttribute("salePriceValue", salePriceStr);
}

request.setAttribute("pageTitle", "Confirm Sale - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="mx-auto w-full max-w-md bg-white rounded-2xl shadow-sm p-8">
  <h2 class="text-2xl font-bold tracking-tight text-slate-900">Confirm Sale</h2>
  <p class="mt-1 text-sm text-slate-600">
    Record a completed transaction for
    <span class="font-semibold text-slate-800">"<%= listingTitle %>"</span>.
    This will mark the item as Sold and log the transaction.
  </p>

  <% String formError = (String) request.getAttribute("formError"); %>
  <% if (formError != null) { %>
    <div class="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
      <%= formError %>
    </div>
  <% } %>

  <div class="mt-4 rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700 flex justify-between">
    <span>Listed price</span>
    <span class="font-semibold text-slate-900">$<%= listingPrice.toPlainString() %></span>
  </div>

  <form class="mt-6 space-y-4" method="post"
        action="<%= request.getContextPath() %>/confirm-sale?id=<%= postId %>">
    <div>
      <label class="block text-sm font-medium text-slate-700" for="buyerEmail">
        Buyer's SJSU Email <span class="text-red-500">*</span>
      </label>
      <input id="buyerEmail" name="buyerEmail" type="email" required
             placeholder="buyer@sjsu.edu"
             value="<%= request.getAttribute("buyerEmailValue") != null ? request.getAttribute("buyerEmailValue") : "" %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div>
      <label class="block text-sm font-medium text-slate-700" for="salePrice">
        Actual Sale Price ($) <span class="text-red-500">*</span>
      </label>
      <input id="salePrice" name="salePrice" type="number" step="0.01" min="0.01" required
             value="<%= request.getAttribute("salePriceValue") != null ? request.getAttribute("salePriceValue") : listingPrice.toPlainString() %>"
             class="mt-1 w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20" />
    </div>

    <div class="flex gap-3">
      <button type="submit"
              class="flex-1 inline-flex items-center justify-center rounded-lg bg-green-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-green-700">
        Confirm Sale
      </button>
      <a href="<%= request.getContextPath() %>/my-listings"
         class="flex-1 inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">
        Cancel
      </a>
    </div>
  </form>
</div>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>