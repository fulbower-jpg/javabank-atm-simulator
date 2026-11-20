package model;

import java.util.List;
import java.util.ArrayList;

/**
 * OOP Demo: INHERITANCE, ENCAPSULATION, POLYMORPHISM
 * - INHERITANCE: Customer extends the abstract User class.
 * - ENCAPSULATION: All properties like isLocked are private and controlled through proper accessors.
 * - POLYMORPHISM: Overrides getDashboardView() to return customer specific dashboard and custom toString().
 */
public class Customer extends User {
    private List<Account> accounts;
    private boolean isLocked;

    public Customer(String userId, String name, String pin, boolean isLocked) {
        super(userId, name, pin, "Customer");
        this.accounts = new ArrayList<>();
        this.isLocked = isLocked;
    }

    public List<Account> getAccounts() {
        return accounts;
    }

    public void setAccounts(List<Account> accounts) {
        this.accounts = accounts;
    }

    public void addAccount(Account account) {
        this.accounts.add(account);
    }

    public boolean isLocked() {
        return isLocked;
    }

    public void setLocked(boolean locked) {
        isLocked = locked;
    }

    @Override
    public String getDashboardView() {
        return "/customer/dashboard.jsp";
    }

    @Override
    public String toString() {
        return "Customer [ID=" + getUserId() + ", Name=" + getName() + ", AccountsCount=" + accounts.size() + ", Locked=" + isLocked + "]";
    }
}
