<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.*, util.FileManager, java.util.List, java.time.LocalDate" %>
<%
    User user = (User) session.getAttribute("loggedUser");
    if (user == null || !(user instanceof Technician)) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=Unauthorized+access.+Staff+Technician+license+required.");
        return;
    }
    Technician tech = (Technician) user;

    // Load ATM data
    String atmLine = FileManager.getAtmInventoryString();
    String[] parts = atmLine.split(",");
    double cashLevel = Double.parseDouble(parts[0]);
    String lastRefill = parts[1];
    int transactionsCount = Integer.parseInt(parts[2].trim());

    // Calculate usage statistics for today
    String todayStr = LocalDate.now().toString(); // e.g. "2026-06-03"
    List<Transaction> txs = FileManager.loadTransactions();
    
    double totalWithdrawn = 0;
    double totalDeposited = 0;
    int todayTxCount = 0;

    for (Transaction t : txs) {
        if (t.getTimestamp().startsWith(todayStr)) {
            todayTxCount++;
            if ("WITHDRAWAL".equalsIgnoreCase(t.getType())) {
                totalWithdrawn += t.getAmount();
            } else if ("DEPOSIT".equalsIgnoreCase(t.getType())) {
                totalDeposited += t.getAmount();
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JavaBank - Technician Dashboard</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <header>
        <div class="logo-section">
            <h1>🏦 JavaBank ATM <span>Staff Portal (Technician)</span></h1>
        </div>
        <div class="user-controls">
            <div class="user-info">
                <p>Welcome, Tech <strong><%= tech.getName() %></strong></p>
                <span>Employee ID: <strong><%= tech.getEmployeeId() %></strong></span>
            </div>
            <a href="../LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </header>

    <div class="content-area" style="max-width: 1000px; margin: 0 auto;">
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
            <h2>ATM Hardware & Cash Vault Reservoirs</h2>
            <p style="color: var(--text-light); font-size: 0.85rem;">Hardware technicians monitor and refill physical currency containers. System database records are restricted.</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card" style="border-left: 4px solid #0284c7;">
                <div class="stat-label">Currency Vault Cash Level</div>
                <div class="stat-value">PKR <%= String.format("%,.2f", cashLevel) %></div>
            </div>
            <div class="stat-card" style="border-left: 4px solid #8b5cf6;">
                <div class="stat-label">Last Refill Date</div>
                <div class="stat-value" style="font-size: 1rem; margin-top: 0.5rem;" class="mono"><%= lastRefill %></div>
            </div>
            <div class="stat-card" style="border-left: 4px solid #10b981;">
                <div class="stat-label">All Tx Count Since Refill</div>
                <div class="stat-value" class="mono"><%= transactionsCount %></div>
            </div>
        </div>

        <div class="layout-columns" style="grid-template-columns: 1.5fr 1fr;">
            
            <!-- Vault Refill form -->
            <div class="main-column">
                <div class="card">
                    <h3 class="card-title">💵 Refill Vault Reserves</h3>
                    <form action="../TechnicianServlet" method="POST">
                        <input type="hidden" name="action" value="refill">

                        <div class="form-group">
                            <label for="amount">Refill Addition Amount (PKR)</label>
                            <input type="number" id="amount" name="amount" min="1000" placeholder="e.g. 50000, 100000" required autocomplete="off">
                            <span style="font-size: 0.75rem; color: var(--text-light);">Increments the vault capacity limits. Minimum addition is PKR 1,000.</span>
                        </div>

                        <button type="submit" class="btn" style="background-color: #0284c7;">Confirm Cash Ingress</button>
                    </form>
                </div>
            </div>

            <!-- reporting panels -->
            <div class="report-column">
                <div class="card" style="border-left: 4px solid #f59e0b;">
                    <h3 class="card-title">📊 Daily Usage Report</h3>
                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                        <div>
                            <p style="font-size: 0.75rem; color: var(--text-light); text-transform: uppercase;">Reporting Date</p>
                            <p style="font-weight: 600;" class="mono"><%= todayStr %></p>
                        </div>
                        <div>
                            <p style="font-size: 0.75rem; color: var(--text-light); text-transform: uppercase;">Total Withdrawn Today</p>
                            <p style="font-weight: 600; color: var(--error-red);" class="mono">PKR <%= String.format("%,.2f", totalWithdrawn) %></p>
                        </div>
                        <div>
                            <p style="font-size: 0.75rem; color: var(--text-light); text-transform: uppercase;">Total Deposited Today</p>
                            <p style="font-weight: 600; color: var(--success-green);" class="mono">PKR <%= String.format("%,.2f", totalDeposited) %></p>
                        </div>
                        <div>
                            <p style="font-size: 0.75rem; color: var(--text-light); text-transform: uppercase;">Total Actions Processed</p>
                            <p style="font-weight: 600;" class="mono"><%= todayTxCount %> txs</p>
                        </div>
                    </div>
                </div>
                
                <%
                    String techLogs = (String) session.getAttribute("techLogs");
                    if (techLogs != null) {
                %>
                    <div class="card" style="background:#0f172a; border-color:#1e293b; color:#38bdf8; padding: 1.25rem;">
                        <span style="font-size: 0.7rem; color:#64748b; text-transform: uppercase; font-weight:600;">⚡ Last Action Logged</span>
                        <p style="font-family: var(--font-mono); font-size:0.75rem; margin-top: 0.25rem;"><%= techLogs %></p>
                    </div>
                <% } %>
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
