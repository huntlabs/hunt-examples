module app.BasicConfigProvider;

import app.BasicApplicationConfig;

import hunt.framework.provider.ServiceProvider;
import hunt.framework.provider.ConfigServiceProvider;
import hunt.framework.application;

import hunt.logging.ConsoleLogger;
import poodinis;


/**
 * 
 */
class BasicConfigProvider : ConfigServiceProvider {
    
    override void register() {
        container.register!(ConfigManager).singleInstance();

        container.register!(ApplicationConfig, BasicApplicationConfig)(() {
            ConfigManager configManager = container.resolve!(ConfigManager)();
            BasicApplicationConfig config = configManager.load!(BasicApplicationConfig);
            return config;
        }).singleInstance();
    }

}