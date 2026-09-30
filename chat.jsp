<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String username =
        (String) session.getAttribute("username");

    if (username == null) {

        response.sendRedirect("login.jsp");

        return;
    }
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Simple Chat</title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css">

</head>


<body class="chat-page">


<div class="chat-app">


    <!-- =================================================
         SIDEBAR
         ================================================= -->

    <aside class="chat-sidebar">


        <!-- SIDEBAR HEADER -->

        <div class="sidebar-header">

            <div class="app-logo">
                💬
            </div>

            <div>

                <h2>Simple Chat</h2>

                <span>
                    Messaging System
                </span>

            </div>

        </div>


        <!-- CURRENT USER -->

        <div class="current-user">

            <div class="avatar avatar-purple">

                <%= username.substring(0, 1).toUpperCase() %>

            </div>

            <div class="current-user-info">

                <strong>
                    <%= username %>
                </strong>

                <span>
                    <span class="online-dot"></span>
                    Online
                </span>

            </div>

        </div>


        <!-- USERS TITLE -->

        <div class="users-heading">

            <span>CONTACTS</span>

            <span id="userCount">0</span>

        </div>


        <!-- USER LIST -->

        <div id="userList" class="user-list">

            <div class="loading-users">
                Loading users...
            </div>

        </div>


        <!-- SIDEBAR FOOTER -->

        <div class="sidebar-footer">

            <a
                href="<%= request.getContextPath() %>/LogoutServlet"
                class="logout-btn">

                <span>↪</span>

                Logout

            </a>

        </div>

    </aside>



    <!-- =================================================
         CHAT MAIN
         ================================================= -->

    <main class="chat-main">


        <!-- EMPTY STATE -->

        <div
            id="emptyChat"
            class="empty-chat">

            <div class="empty-chat-icon">
                💬
            </div>

            <h2>Select a conversation</h2>

            <p>
                Choose a user from the left to start chatting.
            </p>

        </div>



        <!-- ACTIVE CHAT -->

        <div
            id="activeChat"
            class="active-chat hidden">


            <!-- CHAT HEADER -->

            <header class="chat-header">


                <div class="chat-user-info">

                    <div
                        id="chatAvatar"
                        class="avatar avatar-blue">

                        ?

                    </div>

                    <div>

                        <h2 id="chatUser">
                            Select User
                        </h2>

                        <span id="chatStatus">
                            Available to chat
                        </span>

                    </div>

                </div>


                <div class="chat-header-actions">

                    <div
                        id="connectionStatus"
                        class="connection-status">

                        <span class="status-dot"></span>

                        Connected

                    </div>

                </div>

            </header>



            <!-- MESSAGES -->

            <section
                id="messages"
                class="messages-area">

                <div class="no-messages">

                    <div class="no-message-icon">
                        💬
                    </div>

                    <h3>No messages yet</h3>

                    <p>
                        Start the conversation!
                    </p>

                </div>

            </section>



            <!-- MESSAGE INPUT -->

            <footer class="message-area">

                <form
                    id="messageForm"
                    class="message-form">


                    <div class="message-input-wrapper">

                        <input
                            type="text"
                            id="messageInput"
                            placeholder="Type your message..."
                            autocomplete="off"
                            maxlength="1000">

                    </div>


                    <button
                        type="submit"
                        class="send-button">

                        <span>Send</span>

                        <span class="send-icon">
                            ➤
                        </span>

                    </button>

                </form>


                <div class="message-hint">

                    Press Enter to send

                </div>

            </footer>


        </div>

    </main>

</div>



<script>


/* =====================================================
   VARIABLES
   ===================================================== */

const contextPath =
    "<%= request.getContextPath() %>";

const currentUser =
    "<%= username %>";

let selectedUser = null;

let refreshTimer = null;



/* =====================================================
   ELEMENTS
   ===================================================== */

const userList =
    document.getElementById("userList");

const userCount =
    document.getElementById("userCount");

const emptyChat =
    document.getElementById("emptyChat");

const activeChat =
    document.getElementById("activeChat");

const chatUser =
    document.getElementById("chatUser");

const chatAvatar =
    document.getElementById("chatAvatar");

const messages =
    document.getElementById("messages");

const messageForm =
    document.getElementById("messageForm");

const messageInput =
    document.getElementById("messageInput");



/* =====================================================
   LOAD USERS
   ===================================================== */

async function loadUsers() {

    try {

        const response =
            await fetch(
                contextPath +
                "/ChatEndpoint?action=users"
            );


        if (!response.ok) {

            throw new Error(
                "Unable to load users"
            );

        }


        const users =
            await response.json();


        userList.innerHTML = "";

        userCount.textContent =
            users.length;


        if (users.length === 0) {

            userList.innerHTML = `
                <div class="no-users">
                    No other users available
                </div>
            `;

            return;
        }


        users.forEach(function(user) {

            createUser(user);

        });


        if (
            selectedUser &&
            users.includes(selectedUser)
        ) {

            selectUser(selectedUser);

        }

    }

    catch (error) {

        console.error(error);

        userList.innerHTML = `
            <div class="user-error">
                Unable to load users
            </div>
        `;

    }

}



/* =====================================================
   CREATE USER
   ===================================================== */

function createUser(user) {


    const button =
        document.createElement("button");

    button.type = "button";

    button.className =
        "user-item";


    if (user === selectedUser) {

        button.classList.add("active");

    }


    const avatar =
        document.createElement("div");

    avatar.className =
        "avatar avatar-random";

    avatar.textContent =
        user.charAt(0).toUpperCase();


    const details =
        document.createElement("div");

    details.className =
        "user-item-details";


    const name =
        document.createElement("strong");

    name.textContent =
        user;


    const status =
        document.createElement("span");

    status.innerHTML =
        '<span class="online-dot"></span> Available';


    details.appendChild(name);

    details.appendChild(status);


    button.appendChild(avatar);

    button.appendChild(details);


    button.addEventListener(
        "click",
        function() {

            selectUser(user);

        }
    );


    userList.appendChild(button);

}



/* =====================================================
   SELECT USER
   ===================================================== */

function selectUser(user) {


    selectedUser = user;


    emptyChat.classList.add("hidden");

    activeChat.classList.remove("hidden");


    chatUser.textContent =
        user;


    chatAvatar.textContent =
        user.charAt(0).toUpperCase();


    messageInput.focus();


    loadUsers();


    loadMessages();


    startAutoRefresh();

}



/* =====================================================
   LOAD MESSAGES
   ===================================================== */

async function loadMessages() {


    if (!selectedUser) {

        return;

    }


    try {

        const response =
            await fetch(
                contextPath +
                "/ChatEndpoint?action=messages&receiver=" +
                encodeURIComponent(selectedUser)
            );


        if (!response.ok) {

            throw new Error(
                "Unable to load messages"
            );

        }


        const data =
            await response.json();


        displayMessages(data);

    }

    catch (error) {

        console.error(error);

    }

}



/* =====================================================
   DISPLAY MESSAGES
   ===================================================== */

function displayMessages(data) {


    if (!data || data.length === 0) {

        messages.innerHTML = `

            <div class="no-messages">

                <div class="no-message-icon">
                    💬
                </div>

                <h3>No messages yet</h3>

                <p>
                    Start the conversation with ${selectedUser}
                </p>

            </div>

        `;

        return;

    }


    messages.innerHTML = "";


    data.forEach(function(item) {


        const isMine =
            item.sender === currentUser;


        const messageRow =
            document.createElement("div");


        messageRow.className =
            isMine
                ? "message-row sent"
                : "message-row received";


        const bubble =
            document.createElement("div");


        bubble.className =
            "message-bubble";


        const sender =
            document.createElement("div");


        sender.className =
            "message-sender";


        sender.textContent =
            isMine
                ? "You"
                : item.sender;


        const text =
            document.createElement("div");


        text.className =
            "message-text";


        /*
         * textContent is intentional.
         * It prevents HTML from being injected.
         */

        text.textContent =
            item.message;


        const time =
            document.createElement("div");


        time.className =
            "message-time";


        time.textContent =
            item.time;


        bubble.appendChild(sender);

        bubble.appendChild(text);

        bubble.appendChild(time);


        messageRow.appendChild(bubble);


        messages.appendChild(messageRow);

    });


    messages.scrollTop =
        messages.scrollHeight;

}



/* =====================================================
   SEND MESSAGE
   ===================================================== */

messageForm.addEventListener(
    "submit",
    async function(event) {

        event.preventDefault();


        if (!selectedUser) {

            return;

        }


        const message =
            messageInput.value.trim();


        if (!message) {

            return;

        }


        try {

            const response =
                await fetch(
                    contextPath +
                    "/ChatEndpoint",
                    {

                        method: "POST",

                        headers: {
                            "Content-Type":
                                "application/x-www-form-urlencoded"
                        },

                        body:
                            "receiver=" +
                            encodeURIComponent(
                                selectedUser
                            ) +
                            "&message=" +
                            encodeURIComponent(
                                message
                            )

                    }
                );


            if (!response.ok) {

                throw new Error(
                    "Message could not be sent"
                );

            }


            messageInput.value = "";


            await loadMessages();


            messageInput.focus();

        }

        catch (error) {

            console.error(error);

            alert(
                "Unable to send message."
            );

        }

    }
);



/* =====================================================
   ENTER TO SEND
   ===================================================== */

messageInput.addEventListener(
    "keydown",
    function(event) {

        if (
            event.key === "Enter" &&
            !event.shiftKey
        ) {

            event.preventDefault();

            messageForm.requestSubmit();

        }

    }
);



/* =====================================================
   AUTO REFRESH
   ===================================================== */

function startAutoRefresh() {


    if (refreshTimer) {

        clearInterval(refreshTimer);

    }


    refreshTimer =
        setInterval(
            function() {

                if (selectedUser) {

                    loadMessages();

                }

            },
            2000
        );

}



/* =====================================================
   INITIAL LOAD
   ===================================================== */

loadUsers();


</script>


</body>

</html>