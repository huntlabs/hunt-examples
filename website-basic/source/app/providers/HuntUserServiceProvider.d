module app.providers.HuntUserServiceProvider;

import app.data.HuntUserService;

import hunt.framework.provider.UserServiceProvider;
import hunt.framework.auth.UserService;

import hunt.logging.ConsoleLogger;
import poodinis;


/**
 * 
 */
class HuntUserServiceProvider : UserServiceProvider {
    
    override void register() {
        container.register!(UserService, HuntUserService).singleInstance();
    }
}