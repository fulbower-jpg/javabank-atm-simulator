<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JavaBank ATM - Login</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        }
    </style>
</head>
<body>
    <div class="login-wrapper">
        <div class="login-card">
            <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🏦</div>
            <h2>JavaBank ATM</h2>
            <p style="color: var(--text-light); font-size: 0.85rem; margin-bottom: 1.5rem;">Academic Java Servlet & JSP System</p>
            
            <%
                String error = request.getParameter("error");
                String msg = request.getParameter("msg");
                if (error != null) {
            %>
                <div class="alert alert-error" id="errorFlash">
                    <%= error %>
                </div>
            <%
                }
                if (msg != null) {
            %>
                <div class="alert alert-success" id="successFlash">
                    <%= msg %>
                </div>
            <%
                }
            %>

            <form action="LoginServlet" method="POST">
                <div class="form-group" style="text-align: left;">
                    <label for="userId">Card Number / User ID</label>
                    <input type="text" id="userId" name="userId" placeholder="e.g. C001, S001" required autocomplete="off">
                </div>
                
                <div class="form-group" style="text-align: left; margin-bottom: 0.5rem;">
                    <label for="pin">Secure PIN</label>
                    <input type="password" id="pin" name="pin" placeholder="Enter PIN" maxlength="6" required>
                </div>

                <button type="submit" class="btn" style="width: 100%; padding: 0.75rem;">Proceed Securely</button>
            </form>

            <div style="margin-top: 1.5rem; font-size: 0.75rem; color: #94a3b8; text-align: left; border-top: 1px solid #334155; padding-top: 1rem;">
                <p style="font-weight: 600; margin-bottom: 0.25rem;">Academic Demo logins:</p>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:0.25rem;">
                    <span>Client 1: <strong>C001 / 1234</strong></span>
                    <span>Staff Clerk: <strong>S001 / 1111</strong></span>
                    <span>Client 2: <strong>C002 / 5678</strong></span>
                    <span>Staff Tech: <strong>S002 / 2222</strong></span>
                    <span>Client 3: <strong>C003 / 9012 (Lcked)</strong></span>
                    <span>Staff Manager: <strong>S003 / 3333</strong></span>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Auto-dismiss alert notifications after 3 seconds
        setTimeout(function() {
            var errorF = document.getElementById('errorFlash');
            if(errorF) errorF.style.display = 'none';
            var successF = document.getElementById('successFlash');
            if(successF) successF.style.display = 'none';
        }, 3000);
    </script>
</body>
</html>
