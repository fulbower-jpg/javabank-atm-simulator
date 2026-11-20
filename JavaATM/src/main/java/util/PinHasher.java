package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * OOP Demo: ENCAPSULATION
 * Wraps security hashing details inside private algorithmic manipulation.
 * Encapsulates security operations by restricting public exposures to only the hashing contract.
 */
public class PinHasher {
    
    public static String hashPin(String pin) {
        if (pin == null) return null;
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(pin.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not found", e);
        }
    }
}
