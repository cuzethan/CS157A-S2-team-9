import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ListingsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        String q        = trimToEmpty(request.getParameter("q"));
        String location = trimToEmpty(request.getParameter("location"));
        String minPrice = trimToEmpty(request.getParameter("minPrice"));
        String maxPrice = trimToEmpty(request.getParameter("maxPrice"));
        String sort     = trimToEmpty(request.getParameter("sort"));

       
        StringBuilder sql = new StringBuilder(
            "SELECT p.post_ID, p.title, p.price, p.description, p.picture, "
          + "p.item_status, p.email, m.meetup_location "
          + "FROM Posts p "
          + "JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
          + "WHERE p.item_status = 'Available'"
        );
        List<Object> params = new ArrayList<>();

        if (!q.isEmpty()) {
            sql.append(" AND (p.title LIKE ? OR p.description LIKE ?)");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }

        if (!location.isEmpty()) {
            try {
                int locId = Integer.parseInt(location);
                sql.append(" AND p.meetup_id = ?");
                params.add(locId);
            } catch (NumberFormatException ignored) { }
        }

        if (!minPrice.isEmpty()) {
            try {
                BigDecimal min = new BigDecimal(minPrice);
                sql.append(" AND p.price >= ?");
                params.add(min);
            } catch (NumberFormatException ignored) { }
        }

        if (!maxPrice.isEmpty()) {
            try {
                BigDecimal max = new BigDecimal(maxPrice);
                sql.append(" AND p.price <= ?");
                params.add(max);
            } catch (NumberFormatException ignored) { }
        }

        
        if ("price_asc".equals(sort)) {
            sql.append(" ORDER BY p.price ASC");
        } else if ("price_desc".equals(sort)) {
            sql.append(" ORDER BY p.price DESC");
        } else {
            sql.append(" ORDER BY p.post_ID DESC");
        }

       
        List<Map<String, String>> posts = new ArrayList<>();

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof BigDecimal) {
                    ps.setBigDecimal(i + 1, (BigDecimal) param);
                } else if (param instanceof Integer) {
                    ps.setInt(i + 1, (Integer) param);
                } else {
                    ps.setString(i + 1, param.toString());
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> post = new HashMap<>();
                    post.put("id", String.valueOf(rs.getInt("post_ID")));
                    post.put("title", rs.getString("title"));
                    post.put("price", rs.getBigDecimal("price").toPlainString());
                    post.put("description", rs.getString("description"));
                    post.put("picture", rs.getString("picture"));
                    post.put("meetupLocation", rs.getString("meetup_location"));
                    post.put("email", rs.getString("email"));
                    posts.add(post);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

       
        loadMeetupLocations(request);

        
        request.setAttribute("posts", posts);
        request.setAttribute("filterQ", q);
        request.setAttribute("filterLocation", location);
        request.setAttribute("filterMinPrice", minPrice);
        request.setAttribute("filterMaxPrice", maxPrice);
        request.setAttribute("filterSort", sort);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/listings/listings.jsp");
        dispatcher.forward(request, response);
    }

   

    private static void loadMeetupLocations(HttpServletRequest request) {
        List<Map<String, String>> locations = new ArrayList<>();
        String sql = "SELECT meetupID, meetup_location FROM MeetupLocation ORDER BY meetup_location";

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, String> loc = new HashMap<>();
                loc.put("id", String.valueOf(rs.getInt("meetupID")));
                loc.put("name", rs.getString("meetup_location"));
                locations.add(loc);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("meetupLocations", locations);
    }

    private static String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }
}
