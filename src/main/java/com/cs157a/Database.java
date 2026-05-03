package com.cs157a;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Database {
    private static final String DB_NAME = "team_9";
    private static final String USER = "root";
    private static final String PASSWORD = "12345678";
    private static final String URL =
            "jdbc:mysql://localhost:3306/" + DB_NAME + "?autoReconnect=true&useSSL=false";

    static {
        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
