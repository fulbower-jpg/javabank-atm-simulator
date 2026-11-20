<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, util.FileManager, java.util.List" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || !(user instanceof Customer)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Unauthorized+access.+Please+login.");
        return;
    }
    Customer customer = (Customer) user;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JavaBank - Change Secure PIN</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <header>
        <div class="logo-section">
            <h1>🏦 JavaBank ATM <span>Customer Portal</span></h1>
        </div>
        <div class="user-controls">
            <div class="user-info">
                <p>Welcome, <strong><%= customer.getName() %></strong></p>
                <span>Card Number: <%= customer.getUserId() %></span>
            </div>
            <a href="../LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </header>

    <div class="content-area" style="max-width: 500px; margin: 0 auto;">
        <a href="dashboard.jsp" style="text-decoration: none; color: var(--accent-blue); font-size: 0.9rem; font-weight: 500; display: inline-block; margin-bottom: 1.5rem;">&larr; Back to Dashboard</a>

        <div class="card">
            <h3 class="card-title">🔑 Update Security PIN</h3>
            
            <%
                String error = request.getParameter("error");
                if (error != null) {
            %>
                <div class="alert alert-error" id="errorFlash"><%= error %></div>
            <%
                }
            %>

            <form action="../CustomerServlet" method="POST" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="changepin">

                <div class="form-group">
                    <label for="currentPin">Current Secure PIN</label>
                    <input type="password" id="currentPin" name="currentPin" placeholder="Enter current PIN" maxlength="6" required>
                </div>

                <div class="form-group">
                    <label for="newPin">New Secure PIN</label>
                    <input type="password" id="newPin" name="newPin" placeholder="Enter 4-6 digit numeric PIN" maxlength="6" required autocomplete="off">
                </div>

                <div class="form-group">
                    <label for="confirmNewPin">Confirm New PIN</label>
                    <input type="password" id="confirmNewPin" name="confirmNewPin" placeholder="Confirm new PIN" maxlength="6" required autocomplete="off">
                </div>

                <div style="display: flex; gap: 1rem; margin-top: 1rem;">
                    <button type="submit" class="btn" style="flex: 1; background-color: #10b981;">Change PIN</button>
                    <a href="dashboard.jsp" class="btn btn-secondary" style="flex: 1;">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function validateForm() {
            var curr = document.getElementById('currentPin').value;
            var npin = document.getElementById('newPin').value;
            var cpin = document.getElementById('confirmNewPin').value;
            
            if (curr.length < 4 || npin.length < 4 || cpin.length < 4) {
                alert('PIN must be between 4 and 6 digits length.');
                return false;
            }
            if (npin !== cpin) {
                alert('New PIN values must match perfectly.');
                return false;
            }
            if (!/^\d+$/.test(npin)) {
                alert('Secure PIN must contain numeric values only.');
                return false;
            }
            return true;
        }

        setTimeout(function() {
            var errorF = document.getElementById('errorFlash');
            if(errorF) errorF.style.display = 'none';
        }, 3000);
    </script>
</body>
</html>
