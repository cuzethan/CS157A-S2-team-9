<%-- Admin: all transaction records --%>
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
List<Map<String, Object>> allTransactions = new ArrayList<>();
String txSql =
    "SELECT t.transaction_id, t.transaction_date, t.sale_price, "
  + "t.buyer_email, ub.username AS buyer_username, "
  + "t.seller_email, us.username AS seller_username, "
  + "t.post_ID, p.title AS post_title "
  + "FROM Transactions t "
  + "LEFT JOIN Users ub ON ub.email = t.buyer_email "
  + "LEFT JOIN Users us ON us.email = t.seller_email "
  + "LEFT JOIN Posts p  ON p.post_ID = t.post_ID "
  + "ORDER BY t.transaction_date DESC";
try (Connection con = Database.getConnection();
     PreparedStatement ps = con.prepareStatement(txSql);
     ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
        Map<String, Object> tx = new HashMap<>();
        tx.put("id", rs.getInt("transaction_id"));
        tx.put("date", rs.getString("transaction_date"));
        tx.put("price", rs.getBigDecimal("sale_price").toPlainString());
        tx.put("buyerEmail", rs.getString("buyer_email"));
        tx.put("buyerUsername", rs.getString("buyer_username"));
        tx.put("sellerEmail", rs.getString("seller_email"));
        tx.put("sellerUsername", rs.getString("seller_username"));
        tx.put("postTitle", rs.getString("post_title"));
        allTransactions.add(tx);
    }
} catch (SQLException e) {
    e.printStackTrace();
}
%>

<section class="bg-white rounded-2xl shadow-sm p-8 mt-6">
  <div class="flex items-center justify-between">
    <h3 class="text-xl font-semibold text-slate-900">Transaction Records</h3>
    <span class="rounded-lg bg-slate-100 px-3 py-1 text-sm font-medium text-slate-700">
      <%= allTransactions.size() %> total
    </span>
  </div>

  <% if (allTransactions.isEmpty()) { %>
    <div class="mt-6 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-8 text-center text-sm text-slate-600">
      No transactions recorded yet.
    </div>
  <% } else { %>
    <div class="mt-6 overflow-x-auto rounded-xl border border-slate-200">
      <table class="min-w-full divide-y divide-slate-200 text-sm">
        <thead class="bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
          <tr>
            <th class="px-4 py-3 text-left">#</th>
            <th class="px-4 py-3 text-left">Date</th>
            <th class="px-4 py-3 text-left">Item</th>
            <th class="px-4 py-3 text-left">Seller</th>
            <th class="px-4 py-3 text-left">Buyer</th>
            <th class="px-4 py-3 text-right">Sale Price</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <% for (Map<String, Object> tx : allTransactions) { %>
            <tr class="hover:bg-slate-50">
              <td class="px-4 py-3 text-slate-400 font-mono text-xs">#<%= tx.get("id") %></td>
              <td class="px-4 py-3 text-slate-600"><%= tx.get("date") %></td>
              <td class="px-4 py-3 font-medium text-slate-900">
                <%= tx.get("postTitle") != null ? tx.get("postTitle") : "<span class='text-slate-400'>Deleted</span>" %>
              </td>
              <td class="px-4 py-3 text-slate-700">
                <%= tx.get("sellerUsername") != null ? tx.get("sellerUsername") : tx.get("sellerEmail") %>
              </td>
              <td class="px-4 py-3 text-slate-700">
                <%= tx.get("buyerUsername") != null ? tx.get("buyerUsername") : tx.get("buyerEmail") %>
              </td>
              <td class="px-4 py-3 text-right font-semibold text-slate-900">$<%= tx.get("price") %></td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  <% } %>
</section>