package com.chat;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String URL =
            "jdbc:mysql://db01.dbhost.dev:5051/db_454krc7z2"
            + "?useSSL=false"
            + "&allowPublicKeyRetrieval=true"
            + "&serverTimezone=UTC";

    private static final String USER = "user_454krc7z2";

    private static final String PASSWORD = "p454krc7z2";


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null ||
                username.trim().isEmpty() ||
                password.trim().isEmpty()) {

            response.sendRedirect(
                    "login.jsp?error=Please enter username and password");

            return;
        }


        String sql =
                "SELECT username FROM users "
                + "WHERE username = ? AND password = ?";


        try {

            Class.forName("com.mysql.cj.jdbc.Driver");


            try (
                Connection con =
                        DriverManager.getConnection(
                                URL, USER, PASSWORD);

                PreparedStatement ps =
                        con.prepareStatement(sql)
            ) {

                ps.setString(1, username.trim());
                ps.setString(2, password);

                ResultSet rs = ps.executeQuery();


                if (rs.next()) {

                    HttpSession session =
                            request.getSession();

                    session.setAttribute(
                            "username",
                            rs.getString("username")
                    );

                    response.sendRedirect("chat.jsp");

                } else {

                    response.sendRedirect(
                            "login.jsp?error=Invalid username or password"
                    );
                }
            }


        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "login.jsp?error=Database connection error"
            );
        }
    }
}