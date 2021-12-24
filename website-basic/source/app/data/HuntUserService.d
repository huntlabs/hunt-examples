module app.data.HuntUserService;

import hunt.framework;

import hunt.logging;
import std.digest.sha;

/**
 * 
 */
class HuntUserService : UserService {

    enum ADMIN_USER = "admin";
    enum ADMIN_PASSWORD = "admin";

    enum MANAGER_USER = "manager";
    enum MANAGER_PASSWORD = "manager";

    static UserDetails createAdminUser() {
        UserDetails user = new UserDetails();
        user.id = 1;
        user.fullName = "Hunt Admin";
        user.name = ADMIN_USER;
        // user.password = ADMIN_PASSWORD;

        user.roles = ["admin"];
        user.permissions = ["system:*", "user:*"];

        user.salt = generateSalt(ADMIN_USER, ADMIN_PASSWORD);

        return user;
    }

    static UserDetails createManagerUser() {
        UserDetails user = new UserDetails();
        user.id = 2;
        user.fullName = "Hunt Manager";
        user.name = MANAGER_USER;
        // user.password = MANAGER_PASSWORD;

        user.roles = ["manager"];
        user.permissions = ["user:add", "user:edit"];

        user.salt = generateSalt(MANAGER_USER, MANAGER_PASSWORD);

        return user;
    }

    UserDetails authenticate(string name, string password) {

        if(name == ADMIN_USER && password == ADMIN_PASSWORD) {
            return createAdminUser();
        }

        if(name == MANAGER_USER && password == MANAGER_PASSWORD) {
            return createManagerUser();
        }

        return null;
    }

    string getSalt(string name, string password) {
        return generateSalt(name, password);
    }

    static string generateSalt(string name, string password) {
        auto sha256 = new SHA256Digest();
        ubyte[] hash256 = sha256.digest(password~name);
        return toHexString(hash256);        
    }

    UserDetails getByName(string name) {

        if(name == ADMIN_USER) {
            return createAdminUser();
        }

        if(name == MANAGER_USER) {
            return createManagerUser();
        }

        return null;
    }

    UserDetails getById(ulong id) {
        if(id == 1) {
            return createAdminUser();
        }

        if(id == 2) {
            return createManagerUser();
        }
        return null;
    }
}