package model;

import interfaces.StaffAction;

/**
 * OOP Demo: INHERITANCE, POLYMORPHISM, ABSTRACTION
 * - INHERITANCE: Technician extends BankStaff.
 * - POLYMORPHISM: Overrides getDashboardView(), toString(), and performAction().
 * - ABSTRACTION: Implements the StaffAction interface.
 */
public class Technician extends BankStaff implements StaffAction {

    public Technician(String userId, String name, String pin, String employeeId) {
        super(userId, name, pin, "Technician", employeeId);
    }

    @Override
    public String getDashboardView() {
        return "/staff/technician.jsp";
    }

    @Override
    public String performAction(String targetUserId, String details) {
        // Technicians handle cash reservoirs and monitor hardware usage
        if ("REFILL".equalsIgnoreCase(details)) {
            return "Technician [" + getName() + "] refilled ATM with raw cash: PKR " + targetUserId;
        }
        return "Technician [" + getName() + "] reviewed usage logs of the ATM reservoir.";
    }

    @Override
    public String toString() {
        return "Technician [ID=" + getUserId() + ", Name=" + getName() + ", EmployeeID=" + getEmployeeId() + "]";
    }
}
