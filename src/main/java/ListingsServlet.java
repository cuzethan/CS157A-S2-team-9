import java.io.IOException;
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

        List<Map<String, String>> posts = new ArrayList<>();

        String sql = "SELECT p.post_ID, p.title, p.price, p.description, p.picture, "
                   + "p.item_status, p.email, m.meetup_location "
                   + "FROM Posts p "
                   + "LEFT JOIN MeetupLocation m ON p.meetup_id = m.meetupID "
                   + "WHERE p.item_status = 'Available' "
                   + "ORDER BY p.post_ID DESC";

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

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
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("posts", posts);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/listings/listings.jsp");
        dispatcher.forward(request, response);
    }
}
