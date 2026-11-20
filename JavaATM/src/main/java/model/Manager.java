package model;

import interfaces.StaffAction;

/**
 * OOP Demo: INHERITANCE, POLYMORPHISM, ABSTRACTION
 * - INHERITANCE: Manager extends BankStaff.
 * - POLYMORPHISM: Overrides getDashboardView(), toString(), and performAction().
 * - ABSTRACTION: Implements the StaffAction interface.
 */
public class Manager extends BankStaff implements StaffAction {

    public Manager(String userId, String name, String pin, String employeeId) {
        super(userId, name, pin, "Manager", employeeId);
    }

    @Override
    public String getDashboardView() {
        return "/staff/manager.jsp";
    }

    @Override
    public String performAction(String targetUserId, String details) {
        // Managers perform administrative actions like account creation/deletion and system override
        if ("CREATE".equalsIgnoreCase(details)) {
            return "Manager [" + getName() + "] created a new Customer Account with ID: " + targetUserId;
        } else if ("DELETE".equalsIgnoreCase(details)) {
            return "Manager [" + getName() + "] deleted Customer Account with ID: " + targetUserId;
        } else if ("OVERRIDE".equalsIgnoreCase(details)) {
            return "Manager [" + getName() + "] performed System Override on Customer ID: " + targetUserId;
        }
        return "Manager [" + getName() + "] generated full transactional logs audit report.";
    }

    @Override
    public String toString() {
        return "Manager [ID=" + getUserId() + ", Name=" + getName() + ", EmployeeID=" + getEmployeeId() + "]";
    }
}
