module app.BasicApplicationConfig;


import hunt.framework.application.ApplicationConfig;

class BasicApplicationConfigBase : ApplicationConfig {

}

/**
 * 
 */
class BasicApplicationConfig : BasicApplicationConfigBase {

    struct GithubConfig {
        string appid = "1234";
        string secret = "test";
    }

    GithubConfig github;
}