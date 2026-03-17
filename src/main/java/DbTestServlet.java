import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/dbtest")
public class DbTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String db = "";
        String user = "";
        String password = "";

        StringBuilder tableRowsHtml = new StringBuilder();
        boolean statusOk = false;
        String statusMessage;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false",
                    user,
                    password
            );

            statusOk = true;
            statusMessage = db + " database successfully opened. Initial entries in table \"Student\":";

            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM Student");

            while (rs.next()) {
                int id = rs.getInt(1);
                String name = rs.getString(2);
                String major = rs.getString(3);

                tableRowsHtml
                        .append("<tr class=\"hover:bg-slate-50\">")
                        .append("<td class=\"px-3 py-2 text-slate-800\">").append(id).append("</td>")
                        .append("<td class=\"px-3 py-2 text-slate-800\">").append(name).append("</td>")
                        .append("<td class=\"px-3 py-2 text-slate-800\">").append(major).append("</td>")
                        .append("</tr>");
            }

            rs.close();
            stmt.close();
            con.close();
        } catch (ClassNotFoundException e) {
            statusMessage = "JDBC Driver not found: " + e.getMessage();
        } catch (SQLException e) {
            statusMessage = "SQLException caught: " + e.getMessage();
        }

        request.setAttribute("statusOk", statusOk);
        request.setAttribute("statusMessage", statusMessage);
        request.setAttribute("tableRowsHtml", tableRowsHtml.toString());

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/db/dbtest.jsp");
        dispatcher.forward(request, response);
    }
}

