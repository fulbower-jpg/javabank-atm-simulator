package model;

import interfaces.StaffAction;

/**
 * OOP Demo: INHERITANCE, POLYMORPHISM, ABSTRACTION
 * - INHERITANCE: Clerk extends BankStaff.
 * - POLYMORPHISM: Overrides getDashboardView(), toString(), and performAction().
 * - ABSTRACTION: Implements the StaffAction interface.
 */
public class Clerk extends BankStaff implements StaffAction {

    public Clerk(String userId, String name, String pin, String employeeId) {
        super(userId, name, pin, "Clerk", employeeId);
    }

    @Override
    public String getDashboardView() {
        return "/staff/clerk.jsp";
    }

    @Override
    public String performAction(String targetUserId, String details) {
        // Clerks unlock customer accounts and reset failed login attempts
        if ("UNLOCK".equalsIgnoreCase(details)) {
            return "Clerk [" + getName() + "] unlocked Account: " + targetUserId;
        } else if ("RESET_ATTEMPTS".equalsIgnoreCase(details)) {
            return "Clerk [" + getName() + "] reset failed login attempts counter for User: " + targetUserId;
        }
        return "Clerk [" + getName() + "] viewed Customer details for: " + targetUserId;
    }

    @Override
    public String toString() {
        return "Clerk [ID=" + getUserId() + ", Name=" + getName() + ", EmployeeID=" + getEmployeeId() + "]";
    }
}
