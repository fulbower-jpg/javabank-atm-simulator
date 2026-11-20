<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, util.FileManager, java.util.List, java.util.ArrayList" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || !(user instanceof Clerk)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Unauthorized+access.+Staff+Clerk+clearance+required.");
        return;
    }
    Clerk clerk = (Clerk) user;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JavaBank - Clerk Dashboard</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <header>
        <div class="logo-section">
            <h1>🏦 JavaBank ATM <span>Staff Portal (Clerk)</span></h1>
        </div>
        <div class="user-controls">
            <div class="user-info">
                <p>Welcome, Clerk <strong><%= clerk.getName() %></strong></p>
                <span>Employee ID: <strong><%= clerk.getEmployeeId() %></strong></span>
            </div>
            <a href="../LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </header>

    <div class="content-area" style="max-width: 1200px; margin: 0 auto;">
        <%
            String error = request.getParameter("error");
            String msg = request.getParameter("msg");
            if (error != null) {
        %>
            <div class="alert alert-error" id="errorFlash"><%= error %></div>
        <%
            }
            if (msg != null) {
        %>
            <div class="alert alert-success" id="successFlash"><%= msg %></div>
        <%
            }
        %>

        <div style="margin-bottom: 2rem;">
            <h2>Clerk Account Management Panel</h2>
            <p style="color: var(--text-light); font-size: 0.85rem;">Perform actions such as search customer dossiers, unlock locked cards, and clear failed login strikes.</p>
        </div>

        <div class="layout-columns">
            <div class="main-content-column">
                
                <!-- Search Card -->
                <div class="card" style="margin-bottom: 2rem; border-top: 4px solid var(--accent-blue);">
                    <h3 class="card-title">🔍 Search Customer Profile</h3>
                    <form action="clerk.jsp" method="GET" style="flex-direction: row; gap: 1rem; align-items: flex-end;">
                        <input type="hidden" name="action" value="search">
                        <div class="form-group" style="flex: 1;">
                            <label for="searchQuery">Enter Card Number / Customer User ID</label>
                            <input type="text" id="searchQuery" name="searchQuery" value="<%= request.getParameter("searchQuery") != null ? request.getParameter("searchQuery").trim() : "" %>" placeholder="e.g. C001, C002, C003" required autocomplete="off">
                        </div>
                        <button type="submit" class="btn">Search Directory</button>
                        <% if(request.getParameter("searchQuery") != null) { %>
                            <a href="clerk.jsp" class="btn btn-secondary">Clear</a>
                        <% } %>
                    </form>
                </div>

                <!-- Search results card -->
                <%
                    String q = request.getParameter("searchQuery");
                    if (q != null && !q.trim().isEmpty()) {
                        q = q.trim();
                        List<User> users = FileManager.loadUsers();
                        List<Account> accounts = FileManager.loadAccounts();
                        
                        Customer customerResult = null;
                        Account accountResult = null;
                        
                        for (User u : users) {
                            if (u.getUserId().equalsIgnoreCase(q) && u instanceof Customer) {
                                customerResult = (Customer) u;
                                break;
                            }
                        }
                        
                        if (customerResult != null) {
                            for (Account acc : accounts) {
                                if (acc.getOwnerUserId().equalsIgnoreCase(customerResult.getUserId())) {
                                    accountResult = acc;
                                    break;
                                }
                            }
                %>
                    <div class="card" style="border: 1px solid var(--accent-blue); animation: fadeIn 0.4s ease-out;">
                        <h3 class="card-title" style="border-bottom: 1px solid var(--card-border); padding-bottom: 0.75rem;">📋 Dossier: <%= customerResult.getName() %></h3>
                        
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-top: 1rem; margin-bottom: 1.5rem;">
                            <div>
                                <p style="font-size: 0.8rem; color: var(--text-light);">Customer User ID / Card ID</p>
                                <p style="font-size: 1.1rem; font-weight: 600;" class="mono"><%= customerResult.getUserId() %></p>
                            </div>
                            <div>
                                <p style="font-size: 0.8rem; color: var(--text-light);">Account Status</p>
                                <p style="font-size: 1.1rem; font-weight: 600;">
                                    <% if (customerResult.isLocked()) { %>
                                        <span style="color: var(--error-red); background-color: #fef2f2; padding: 0.15rem 0.5rem; border: 1px solid #fecaca; border-radius: 4px;">⛔ LOCKED</span>
                                    <% } else { %>
                                        <span style="color: var(--success-green); background-color: #f0fdf4; padding: 0.15rem 0.5rem; border: 1px solid #bbf7d0; border-radius: 4px;">✅ ACTIVE</span>
                                    <% } %>
                                </p>
                            </div>
                            <div>
                                <p style="font-size: 0.8rem; color: var(--text-light);">Linked Account ID</p>
                                <p style="font-size: 1.1rem; font-weight: 600;" class="mono"><%= accountResult != null ? accountResult.getAccountId() : "Unassigned" %></p>
                            </div>
                            <div>
                                <p style="font-size: 0.8rem; color: var(--text-light);">Current Ledger Balance</p>
                                <p style="font-size: 1.1rem; font-weight: 600; color: var(--accent-blue);" class="mono">
                                    <%= accountResult != null ? "PKR " + String.format("%,.2f", accountResult.getBalance()) : "N/A" %>
                                </p>
                            </div>
                        </div>

                        <!-- Clerk Actions form submissions -->
                        <div style="display: flex; gap: 1rem; margin-top: 1.5rem; border-top: 1px solid var(--card-border); padding-top: 1.5rem;">
                            <% if (customerResult.isLocked()) { %>
                                <form action="../ClerkServlet" method="POST" style="display: inline-block;">
                                    <input type="hidden" name="action" value="unlock">
                                    <input type="hidden" name="customerId" value="<%= customerResult.getUserId() %>">
                                    <button type="submit" class="btn" style="background-color: var(--success-green);">🔓 Unlock Account Card</button>
                                </form>
                            <% } %>
                            
                            <form action="../ClerkServlet" method="POST" style="display: inline-block;">
                                <input type="hidden" name="action" value="reset_attempts">
                                <input type="hidden" name="customerId" value="<%= customerResult.getUserId() %>">
                                <button type="submit" class="btn btn-secondary">🔄 Reset Login strikes count</button>
                            </form>
                        </div>

                        <!-- Recent search customer logs -->
                        <h4 style="margin-top: 2rem; margin-bottom: 0.75rem; font-size: 0.95rem; font-weight: 600;">Activity Summary Logs Handled</h4>
                        <table>
                            <thead>
                                <tr>
                                    <th>Timestamp</th>
                                    <th>TX ID</th>
                                    <th>Type</th>
                                    <th>Amount (PKR)</th>
                                    <th>Notes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (accountResult != null) {
                                        List<Transaction> txsList = FileManager.loadTransactions();
                                        int txCount = 0;
                                        for (int i = txsList.size() - 1; i >= 0; i--) {
                                            Transaction t = txsList.get(i);
                                            if (t.getAccountId().equalsIgnoreCase(accountResult.getAccountId())) {
                                                txCount++;
                                %>
                                                <tr>
                                                    <td class="mono"><%= t.getTimestamp() %></td>
                                                    <td class="mono"><%= t.getTxnId() %></td>
                                                    <td class="mono" style="font-weight:600; color:<%= t.getType().equals("DEPOSIT") ? "var(--success-green)" : "var(--error-red)" %>;"><%= t.getType() %></td>
                                                    <td class="mono">PKR <%= String.format("%,.2f", t.getAmount()) %></td>
                                                    <td><%= t.getNotes() %></td>
                                                </tr>
                                <%
                                                if (txCount >= 5) break;
                                            }
                                        }
                                        if (txCount == 0) {
                                %>
                                            <tr>
                                                <td colspan="5" style="text-align: center; color: var(--text-light);">No activity summaries logged for searched account.</td>
                                            </tr>
                                <%
                                        }
                                    } else {
                                %>
                                        <tr>
                                            <td colspan="5" style="text-align: center; color: var(--text-light);">No linked Account profile linked.</td>
                                        </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <%
                        } else {
                %>
                    <div class="alert alert-error">No customer profiles matched the Query: <strong><%= q %></strong></div>
                <%
                        }
                    }
                %>
            </div>

            <!-- session log auditor tracker table -->
            <div class="sidebar-column" style="width: 320px;">
                <div class="card" style="padding: 1.5rem; background: #0f172a; border-color: #1e293b; color: #38bdf8;">
                    <h3 class="card-title" style="color: white; border-bottom: 1px solid #1e293b; padding-bottom: 0.5rem; font-size: 0.9rem;">📝 Clerk Session Audit</h3>
                    
                    <div class="sidebar-logs" style="padding:0; margin-top:1rem; max-height: 450px;">
                        <%
                            @SuppressWarnings("unchecked")
                            List<String> list = (List<String>) session.getAttribute("clerkLogs");
                            if (list == null || list.isEmpty()) {
                        %>
                            <p style="color: #64748b; font-style: italic; font-size: 0.8rem;">No actions taken in today's active session logs.</p>
                        <%
                            } else {
                                for (String l : list) {
                        %>
                            <div style="border-bottom: 1px dashed #1e293b; padding: 0.5rem 0; font-size:0.75rem; color:#a5f3fc; line-height: 1.4;">
                                <span>⚡ <%= l %></span>
                            </div>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        setTimeout(function() {
            var errorF = document.getElementById('errorFlash');
            if(errorF) errorF.style.display = 'none';
            var successF = document.getElementById('successFlash');
            if(successF) successF.style.display = 'none';
        }, 3000);
    </script>
</body>
</html>
