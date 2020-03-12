module app.BasicConfigProvider;

import app.config.BasicApplicationConfig;

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
            return configManager.load!(BasicApplicationConfig);
        }).singleInstance();
        
        container.register!(RouteConfig)(() {
            ConfigManager configManager = container.resolve!(ConfigManager)();
            ApplicationConfig appConfig = container.resolve!(ApplicationConfig)();
            RouteConfig routeConfig = new RouteConfig(appConfig);
            routeConfig.basePath = configManager.configPath();

            return routeConfig;
        });
    }

}