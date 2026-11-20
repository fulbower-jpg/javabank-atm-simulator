package model;

/**
 * OOP Demo: ABSTRACTION, INHERITANCE, ENCAPSULATION
 * - ABSTRACTION: User is abstract and cannot be instantiated directly. Declares abstract getDashboardView().
 * - INHERITANCE: Serves as the parent class for Customer and BankStaff.
 * - ENCAPSULATION: All fields are private and accessed via public getters/setters.
 */
public abstract class User {
    private String userId;
    private String name;
    private String pin; // Private field holding hashed PIN, compared internally, never returned.
    private String role;

    public User(String userId, String name, String pin, String role) {
        this.userId = userId;
        this.name = name;
        this.pin = pin;
        this.role = role;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // Encapsulation checking logic internally, NEVER return the PIN directly
    public boolean verifyPin(String hashedPinInput) {
        return this.pin.equals(hashedPinInput);
    }

    public void updatePin(String hashedNewPin) {
        this.pin = hashedNewPin;
    }

    // Useful for serializing to file
    public String getHashedPinForStorage() {
        return pin;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    // Abstract method: demonstrating Abstraction and Polymorphism
    public abstract String getDashboardView();

    @Override
    public abstract String toString();
}
