module app.BasicApplicationConfig;

import hunt.framework.application.ApplicationConfig;
import hunt.util.Configuration;

class BasicApplicationConfigBase : ApplicationConfig {

}

/**
 * 
 */
// @Configuration("hunt")
class BasicApplicationConfig : BasicApplicationConfigBase {

    struct GithubConfig {
        string appid = "1234";
        string secret = "test";
    }

    GithubConfig github;
}