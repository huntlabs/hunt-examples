module app.providers.BasicAuthServiceProvider;


// import app.auth;

import hunt.framework.provider;
import hunt.framework.auth;
import hunt.shiro;

import hunt.logging;
import poodinis;

class BasicAuthServiceProvider : AuthServiceProvider {
    
    override void boot() {
        AuthService authService = container().resolve!AuthService();
        // authService.addGuard(new BasicGuard());
        authService.addGuard(new JwtGuard());

        authService.boot();
    }
}