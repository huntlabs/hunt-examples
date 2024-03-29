module app.providers.BasicConfigProvider;

import app.config.BasicApplicationConfig;

import hunt.framework.provider.ServiceProvider;
import hunt.framework.provider.ConfigServiceProvider;
import hunt.framework.application;
import hunt.framework.config;
import hunt.framework.routing;

import hunt.logging;
import poodinis;


/**
 * 
 */
class BasicConfigProvider : ConfigServiceProvider {
    
    // override void register() {
    //     container.register!(ConfigManager).singleInstance();

    //     container.register!(ApplicationConfig, BasicApplicationConfig)(() {
    //         ConfigManager configManager = container.resolve!(ConfigManager)();
    //         return configManager.load!(BasicApplicationConfig);
    //     }).singleInstance();
        
    //     container.register!(RouteConfigManager)(() {
    //         ConfigManager configManager = container.resolve!(ConfigManager)();
    //         ApplicationConfig appConfig = container.resolve!(ApplicationConfig)();
    //         RouteConfigManager routeConfig = new RouteConfigManager(appConfig);
    //         routeConfig.basePath = configManager.configPath();

    //         return routeConfig;
    //     });
    // }

    override void registerApplicationConfig() {
        container.register!(ApplicationConfig, BasicApplicationConfig).initializedBy(() {
            ConfigManager configManager = container.resolve!(ConfigManager)();
            return configManager.load!(BasicApplicationConfig);
        }).singleInstance();
    }

}