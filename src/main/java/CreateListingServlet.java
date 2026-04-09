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
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CreateListingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("emailValue") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        loadMeetupLocations(request);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/listings/create-listing.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("emailValue") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String email = (String) session.getAttribute("emailValue");
        String title = trimToNull(request.getParameter("title"));
        String priceStr = trimToNull(request.getParameter("price"));
        String description = trimToNull(request.getParameter("description"));
        String picture = trimToNull(request.getParameter("picture"));
        String locationDetails = trimToNull(request.getParameter("locationDetails"));
        String meetupIdStr = trimToNull(request.getParameter("meetupId"));

        
        request.setAttribute("titleValue", title);
        request.setAttribute("priceValue", priceStr);
        request.setAttribute("descriptionValue", description);
        request.setAttribute("pictureValue", picture);
        request.setAttribute("locationValue", locationDetails);
        request.setAttribute("meetupValue", meetupIdStr);

        
        String error = validate(title, priceStr, description, meetupIdStr);
        if (error != null) {
            request.setAttribute("formError", error);
            loadMeetupLocations(request);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/listings/create-listing.jsp");
            dispatcher.forward(request, response);
            return;
        }

        BigDecimal price = new BigDecimal(priceStr);
        int meetupId = Integer.parseInt(meetupIdStr);

        String sql = "INSERT INTO Posts (title, price, description, picture, location_details_specific, item_status, email, meetup_id) "
                   + "VALUES (?, ?, ?, ?, ?, 'Available', ?, ?)";

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, title);
            ps.setBigDecimal(2, price);
            ps.setString(3, description);
            ps.setString(4, picture);
            ps.setString(5, locationDetails);
            ps.setString(6, email);
            ps.setInt(7, meetupId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("formError", "Database error: " + e.getMessage());
            loadMeetupLocations(request);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/listings/create-listing.jsp");
            dispatcher.forward(request, response);
            return;
        }

       
        response.sendRedirect(request.getContextPath() + "/listings");
    }

    private static String validate(String title, String priceStr, String description, String meetupId) {
        if (title == null || title.isEmpty()) {
            return "Item title is required.";
        }
        if (title.length() > 45) {
            return "Item title must be 45 characters or fewer.";
        }
        if (priceStr == null || priceStr.isEmpty()) {
            return "Price is required.";
        }
        try {
            BigDecimal price = new BigDecimal(priceStr);
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                return "Price must be greater than $0.00.";
            }
        } catch (NumberFormatException e) {
            return "Price must be a valid number.";
        }
        if (description == null || description.isEmpty()) {
            return "Description is required.";
        }
        if (meetupId == null || meetupId.isEmpty()) {
            return "Meetup location is required.";
        }
        return null;
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

    private static String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
