module app.config.GithubConfig;

import hunt.util.Configuration;

@ConfigurationFile("github")
class GithubConfig {
    string appid = "12345";
    string secret = "test-github";
    string accessTokenUrl = "TokenUrl";
    string userInfoUrl = "InfoUrl";
}


@ConfigurationFile("app")
class AppConfig{
    QimenConfig qimen;
    string accessTokenUrl = "TokenUrl";
}

struct QimenConfig{
    bool checksign;
    string url;
    string app_key;
    string secret ;
}
