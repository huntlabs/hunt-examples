module app.config.BasicApplicationConfig;

import hunt.framework.config.ApplicationConfig;
import hunt.util.Configuration;

class BasicApplicationConfigBase : ApplicationConfig {

}

/**
 * 
 */
// @Configuration("hunt")
@ConfigurationFile("application")
class BasicApplicationConfig : BasicApplicationConfigBase {

    struct GithubConfig {
        string appid = "1234";
        string secret = "test";
    }

    GithubConfig github;
}