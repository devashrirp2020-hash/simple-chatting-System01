package com.chat;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/ChatEndpoint")
public class ChatEndpoint extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // MySQL Database
    private static final String URL =
            "jdbc:mysql://db01.dbhost.dev:5051/db_454krc7z2"
            + "?useSSL=false"
            + "&allowPublicKeyRetrieval=true"
            + "&serverTimezone=UTC";

    private static final String USER = "user_454krc7z2";
    private static final String PASSWORD = "p454krc7z2";

    // Database connection
    private Connection getConnection() throws Exception {

        Class.forName("com.mysql.cj.jdbc.Driver");

        return DriverManager.getConnection(
                URL,
                USER,
                PASSWORD
        );
    }

    // =========================
    // GET REQUEST
    // =========================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        // Check login
        if (session == null ||
                session.getAttribute("username") == null) {

            response.setStatus(
                    HttpServletResponse.SC_UNAUTHORIZED);

            return;
        }

        String action =
                request.getParameter("action");

        if ("users".equals(action)) {

            getUsers(request, response);

        } else if ("messages".equals(action)) {

            getMessages(request, response);

        } else {

            response.setStatus(
                    HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    // =========================
    // POST REQUEST
    // SEND MESSAGE
    // =========================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        // Check login
        if (session == null ||
                session.getAttribute("username") == null) {

            response.setStatus(
                    HttpServletResponse.SC_UNAUTHORIZED);

            return;
        }

        String sender =
                (String) session.getAttribute("username");

        String receiver =
                request.getParameter("receiver");

        String message =
                request.getParameter("message");

        // Validate data
        if (receiver == null ||
                receiver.trim().isEmpty() ||
                message == null ||
                message.trim().isEmpty()) {

            response.setStatus(
                    HttpServletResponse.SC_BAD_REQUEST);

            return;
        }

        String sql =
                "INSERT INTO messages "
                + "(sender, receiver, message) "
                + "VALUES (?, ?, ?)";

        response.setContentType(
                "application/json;charset=UTF-8");

        try (
            Connection con = getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(1, sender);
            ps.setString(2, receiver.trim());
            ps.setString(3, message.trim());

            ps.executeUpdate();

            response.getWriter().write(
                    "{\"status\":\"success\"}"
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            response.getWriter().write(
                    "{\"status\":\"error\"}"
            );
        }
    }

    // =========================
    // GET USERS
    // =========================

    private void getUsers(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session =
                request.getSession(false);

        String currentUser =
                (String) session.getAttribute("username");

        String sql =
                "SELECT username FROM users "
                + "WHERE username <> ? "
                + "ORDER BY username";

        response.setContentType(
                "application/json;charset=UTF-8");

        StringBuilder json =
                new StringBuilder("[");

        try (
            Connection con = getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(1, currentUser);

            ResultSet rs =
                    ps.executeQuery();

            boolean first = true;

            while (rs.next()) {

                if (!first) {
                    json.append(",");
                }

                first = false;

                json.append("\"")
                    .append(
                        escapeJson(
                            rs.getString("username")
                        )
                    )
                    .append("\"");
            }

            json.append("]");

            response.getWriter().write(
                    json.toString()
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            response.getWriter().write(
                    "{\"error\":\"Database error\"}"
            );
        }
    }

    // =========================
    // GET MESSAGES
    // =========================

    private void getMessages(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session =
                request.getSession(false);

        String currentUser =
                (String) session.getAttribute("username");

        String receiver =
                request.getParameter("receiver");

        if (receiver == null ||
                receiver.trim().isEmpty()) {

            response.setStatus(
                    HttpServletResponse.SC_BAD_REQUEST);

            return;
        }

        String sql =
                "SELECT sender, receiver, message, message_time "
                + "FROM messages "
                + "WHERE "
                + "(sender = ? AND receiver = ?) "
                + "OR "
                + "(sender = ? AND receiver = ?) "
                + "ORDER BY message_time ASC";

        response.setContentType(
                "application/json;charset=UTF-8");

        StringBuilder json =
                new StringBuilder("[");

        try (
            Connection con = getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setString(1, currentUser);
            ps.setString(2, receiver);

            ps.setString(3, receiver);
            ps.setString(4, currentUser);

            ResultSet rs =
                    ps.executeQuery();

            boolean first = true;

            SimpleDateFormat format =
                    new SimpleDateFormat(
                            "dd-MM-yyyy HH:mm:ss"
                    );

            while (rs.next()) {

                if (!first) {
                    json.append(",");
                }

                first = false;

                String sender =
                        rs.getString("sender");

                String receiverName =
                        rs.getString("receiver");

                String message =
                        rs.getString("message");

                Timestamp timestamp =
                        rs.getTimestamp("message_time");

                String time =
                        format.format(timestamp);

                json.append("{");

                json.append("\"sender\":\"")
                    .append(escapeJson(sender))
                    .append("\",");

                json.append("\"receiver\":\"")
                    .append(escapeJson(receiverName))
                    .append("\",");

                json.append("\"message\":\"")
                    .append(escapeJson(message))
                    .append("\",");

                json.append("\"time\":\"")
                    .append(escapeJson(time))
                    .append("\"");

                json.append("}");
            }

            json.append("]");

            response.getWriter().write(
                    json.toString()
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

            response.getWriter().write(
                    "{\"error\":\"Database error\"}"
            );
        }
    }

    // =========================
    // JSON ESCAPE
    // =========================

    private String escapeJson(String text) {

        if (text == null) {
            return "";
        }

        return text
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}