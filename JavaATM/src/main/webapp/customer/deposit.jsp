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
    <title>JavaBank - Deposit Cash</title>
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

    <div class="content-area" style="max-width: 600px; margin: 0 auto;">
        <a href="dashboard.jsp" style="text-decoration: none; color: var(--accent-blue); font-size: 0.9rem; font-weight: 500; display: inline-block; margin-bottom: 1.5rem;">&larr; Back to Dashboard</a>

        <div class="card">
            <h3 class="card-title">💵 Deposit Cash Reservoir</h3>
            
            <%
                String error = request.getParameter("error");
                if (error != null) {
            %>
                <div class="alert alert-error" id="errorFlash"><%= error %></div>
            <%
                }
            %>

            <form action="../CustomerServlet" method="POST">
                <input type="hidden" name="action" value="deposit">

                <div class="form-group">
                    <label for="amount">Deposit Amount (PKR)</label>
                    <input type="number" id="amount" name="amount" min="1" placeholder="Enter amount to deposit" required autocomplete="off">
                    <span style="font-size: 0.75rem; color: var(--text-light);">Minimum allowed deposit is PKR 1.</span>
                </div>

                <div class="form-group">
                    <label for="note">Transaction Note (Optional)</label>
                    <input type="text" id="note" name="note" placeholder="e.g. Salary, Gift, Cash deposit" autocomplete="off">
                    <span style="font-size: 0.75rem; color: var(--text-light);">Used to demonstrate dynamic Method Overloading in Account classes.</span>
                </div>

                <div style="display: flex; gap: 1rem; margin-top: 1rem;">
                    <button type="submit" class="btn" style="flex: 1;">Confirm Deposit</button>
                    <a href="dashboard.jsp" class="btn btn-secondary" style="flex: 1;">Cancel</a>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        setTimeout(function() {
            var errorF = document.getElementById('errorFlash');
            if(errorF) errorF.style.display = 'none';
        }, 3000);
    </script>
</body>
</html>
