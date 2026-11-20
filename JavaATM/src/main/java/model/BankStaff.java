package model;

/**
 * OOP Demo: INHERITANCE, ABSTRACTION, ENCAPSULATION
 * - INHERITANCE: BankStaff extends the User base class.
 * - ABSTRACTION: BankStaff is itself abstract and cannot be directly instantiated.
 * - ENCAPSULATION: Private field employeeId with getter/setter.
 */
public abstract class BankStaff extends User {
    private String employeeId;

    public BankStaff(String userId, String name, String pin, String role, String employeeId) {
        super(userId, name, pin, role);
        this.employeeId = employeeId;
    }

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }

    @Override
    public abstract String getDashboardView();

    @Override
    public abstract String toString();
}
