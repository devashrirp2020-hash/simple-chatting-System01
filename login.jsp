<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Simple Chat - Login</title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css">

</head>

<body class="login-page">

    <div class="login-bg-circle circle-1"></div>
    <div class="login-bg-circle circle-2"></div>
    <div class="login-bg-circle circle-3"></div>


    <div class="login-wrapper">


        <!-- LEFT SIDE -->

        <div class="login-brand">

            <div class="brand-logo">
                <span>💬</span>
            </div>

            <h1>Simple Chat</h1>

            <p class="brand-description">
                Connect with your friends and exchange
                messages instantly.
            </p>


            <div class="brand-features">

                <div class="brand-feature">
                    <div class="feature-icon">✓</div>
                    <div>
                        <strong>Easy Messaging</strong>
                        <small>Send messages instantly</small>
                    </div>
                </div>


                <div class="brand-feature">
                    <div class="feature-icon">✓</div>
                    <div>
                        <strong>Multiple Users</strong>
                        <small>Chat with different users</small>
                    </div>
                </div>


                <div class="brand-feature">
                    <div class="feature-icon">✓</div>
                    <div>
                        <strong>Live Updates</strong>
                        <small>Messages refresh automatically</small>
                    </div>
                </div>

            </div>

        </div>


        <!-- RIGHT SIDE -->

        <div class="login-card">

            <div class="login-card-header">

                <div class="mobile-logo">
                    💬
                </div>

                <h2>Welcome Back</h2>

                <p>
                    Sign in to continue to your chat
                </p>

            </div>


            <%
                String error = request.getParameter("error");

                if (error != null && !error.isEmpty()) {
            %>

                <div class="login-error">
                    <span>⚠</span>
                    <span><%= error %></span>
                </div>

            <%
                }
            %>


            <form
                action="<%= request.getContextPath() %>/LoginServlet"
                method="post"
                class="login-form">


                <!-- USERNAME -->

                <div class="input-group">

                    <label for="username">
                        Username
                    </label>

                    <div class="input-box">

                        <span class="input-symbol">
                            👤
                        </span>

                        <input
                            type="text"
                            id="username"
                            name="username"
                            placeholder="Enter your username"
                            required
                            autocomplete="username">

                    </div>

                </div>


                <!-- PASSWORD -->

                <div class="input-group">

                    <label for="password">
                        Password
                    </label>

                    <div class="input-box">

                        <span class="input-symbol">
                            🔒
                        </span>

                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Enter your password"
                            required
                            autocomplete="current-password">

                        <button
                            type="button"
                            class="show-password"
                            onclick="togglePassword()">

                            👁

                        </button>

                    </div>

                </div>


                <button
                    type="submit"
                    class="login-btn">

                    <span>Login to Chat</span>

                    <span class="btn-arrow">→</span>

                </button>

            </form>


            <div class="login-status">

                <span class="status-dot"></span>

                Chat server is available

            </div>

        </div>

    </div>


    <script>

        function togglePassword() {

            const password =
                document.getElementById("password");

            const button =
                document.querySelector(".show-password");


            if (password.type === "password") {

                password.type = "text";

                button.textContent = "🙈";

            } else {

                password.type = "password";

                button.textContent = "👁";

            }

        }

    </script>

</body>

</html>