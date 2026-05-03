<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs157a.Database" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
javax.servlet.http.HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("emailValue") == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}
String email = (String) userSession.getAttribute("emailValue");

// Load all transactions where this user was buyer or seller
String sql =
    "SELECT t.transaction_id, t.transaction_date, t.sale_price, "
  + "t.buyer_email, ub.username AS buyer_username, "
  + "t.seller_email, us.username AS seller_username, "
  + "t.post_ID, p.title AS post_title "
  + "FROM Transactions t "
  + "LEFT JOIN Users ub ON ub.email = t.buyer_email "
  + "LEFT JOIN Users us ON us.email = t.seller_email "
  + "LEFT JOIN Posts p  ON p.post_ID = t.post_ID "
  + "WHERE t.buyer_email = ? OR t.seller_email = ? "
  + "ORDER BY t.transaction_date DESC";

List<Map<String, Object>> transactions = new ArrayList<>();
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(sql)) {
    ps.setString(1, email);
    ps.setString(2, email);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Map<String, Object> tx = new HashMap<>();
            tx.put("id", rs.getInt("transaction_id"));
            tx.put("date", rs.getString("transaction_date"));
            tx.put("price", rs.getBigDecimal("sale_price").toPlainString());
            tx.put("buyerEmail", rs.getString("buyer_email"));
            tx.put("buyerUsername", rs.getString("buyer_username"));
            tx.put("sellerEmail", rs.getString("seller_email"));
            tx.put("sellerUsername", rs.getString("seller_username"));
            tx.put("postId", rs.getInt("post_ID"));
            tx.put("postTitle", rs.getString("post_title"));
            tx.put("role", email.equals(rs.getString("seller_email")) ? "Seller" : "Buyer");
            transactions.add(tx);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}

request.setAttribute("pageTitle", "My Transactions - SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
  <div>
    <h2 class="text-2xl font-bold tracking-tight text-slate-900">My Transactions</h2>
    <p class="mt-1 text-sm text-slate-600">A record of all your completed sales and purchases.</p>
  </div>
</div>

<% if (transactions.isEmpty()) { %>
  <div class="mt-8 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-10 text-center">
    <p class="text-sm font-semibold text-slate-900">No transactions yet</p>
    <p class="mt-1 text-sm text-slate-600">
      Transactions appear here once you confirm a sale on one of your listings.
    </p>
  </div>
<% } else { %>
  <div class="mt-6 bg-white rounded-2xl shadow-sm overflow-hidden">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-slate-200 text-sm">
        <thead class="bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
          <tr>
            <th class="px-5 py-3 text-left">#</th>
            <th class="px-5 py-3 text-left">Date</th>
            <th class="px-5 py-3 text-left">Item</th>
            <th class="px-5 py-3 text-left">Role</th>
            <th class="px-5 py-3 text-left">Counterpart</th>
            <th class="px-5 py-3 text-right">Sale Price</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <% for (Map<String, Object> tx : transactions) {
               boolean isSeller = "Seller".equals(tx.get("role"));
               String counterUsername = isSeller
                   ? (String) tx.get("buyerUsername")
                   : (String) tx.get("sellerUsername");
               String counterEmail = isSeller
                   ? (String) tx.get("buyerEmail")
                   : (String) tx.get("sellerEmail");
          %>
            <tr class="hover:bg-slate-50">
              <td class="px-5 py-3 text-slate-400 font-mono text-xs">#<%= tx.get("id") %></td>
              <td class="px-5 py-3 text-slate-600"><%= tx.get("date") %></td>
              <td class="px-5 py-3 font-medium text-slate-900"><%= tx.get("postTitle") != null ? tx.get("postTitle") : "Deleted listing" %></td>
              <td class="px-5 py-3">
                <span class="inline-flex rounded-full px-2 py-0.5 text-[11px] font-semibold
                             <%= isSeller ? "bg-green-100 text-green-700" : "bg-blue-100 text-blue-700" %>">
                  <%= tx.get("role") %>
                </span>
              </td>
              <td class="px-5 py-3 text-slate-600">
                <%= counterUsername != null ? counterUsername : counterEmail %>
              </td>
              <td class="px-5 py-3 text-right font-semibold text-slate-900">$<%= tx.get("price") %></td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </div>
<% } %>

<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>