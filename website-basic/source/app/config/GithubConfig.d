module app.config.GithubConfig;

import hunt.util.Configuration;

@ConfigurationFile("github")
class GithubConfig {
    string appid = "12345";
    string secret = "test-github";
    string accessTokenUrl = "TokenUrl";
    string userInfoUrl = "InfoUrl";
}