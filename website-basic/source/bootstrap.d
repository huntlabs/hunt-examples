/*
 * Hunt - Hunt is a high-level D Programming Language Web framework that encourages rapid development and clean, pragmatic design. It lets you build high-performance Web applications quickly and easily.
 *
 * Copyright (C) 2015-2016  Shanghai Putao Technology Co., Ltd 
 *
 * Developer: putao's Dlang team
 *
 * Licensed under the BSD License.
 *
 */

module bootstrap;

import app.providers;
import app.middleware;
import app.config.GithubConfig;

import hunt.console;
import hunt.framework;
import hunt.logging.Logger;
import core.thread;
import std.datetime;
import std.stdio;
import std.functional;


import hunt.io.channel.Common;

import hunt.entity;
import hunt.cache;

import hunt.serialization.JsonSerializer;


import hunt.serialization;

void main1(string[] args) {
    // UserDetails ud = new UserDetails();
    // ud.name = "test";

    // string js = toJson(ud);

    // trace(js);
}

void main(string[] args)
{
    // Application app = Application.getInstance();
	// app.withStompBroker().onConfiguration((MessageBrokerRegistry config) {
    //     config.enableSimpleBroker("/topic");
    //     config.setApplicationDestinationPrefixes("/app");
    // })
    // .onStompEndpointsRegister((StompEndpointRegistry registry) {
    //     // https://blog.csdn.net/a617137379/article/details/78765025?utm_source=blogxgwz6
    //     // https://github.com/rstoyanchev/spring-websocket-portfolio/issues/14
    //     registry.addEndpoint("/gs-guide-websocket").setAllowedOrigins("*");
    // })
    // .onText((text, conn) { 
    //     writeln("The server received: " ~ text); 
    //     conn.sendText(Clock.currTime.toString() ~ ": " ~ text);
    // }).start();

    // testI18n();
    // testConsole(args);


    // example 3
    Application app = Application.instance();
    // app.enableLocale("./resources/translations");

    // grpc start

    // import service.MyService;
    // auto server = app().grpc().server();
    // server.register(MyService);

    // grpc end

    // writeln(trans("title"));
    // writeln(trans("title%s"));
    // writeln(transf("title", "Hunt"));

    // writeln(transWithLocale("zh-cn", "title"));
    // writeln(transWithLocale("zh-cn", "title", "Hunt"));
    app.register!BasicAuthServiceProvider; 
    app.register!BasicConfigProvider; 
    app.register!BreadcrumbProvider;
    // app.register!HuntUserServiceProvider; 

    app.booting(() {
        import GreeterImpl;
        // app.grpc.server.register( new GreeterImpl());
    });

    app.booted(() {

        AppConfig githubConfig = configManager().load!AppConfig();
        warning(githubConfig.qimen.url);


        TypeInfo_Class[string] all = MiddlewareInterface.all();
        foreach(string key, TypeInfo_Class typeInfo; all) {
            infof("Registed middleware: %s => %s", key, typeInfo.toString());
        }

        // RouteGroup apiGroup = app.route().group("api");

        RouteGroup adminGroup = app.route().group("admin");
        tracef("admin guard: %s", adminGroup.guardName);
        adminGroup.guardName = DEFAULT_GURAD_NAME;

        // app.route().get("index.about").withoutMiddleware!(AuthMiddleware)();
        // app.route().get("index.security").withMiddleware!(AuthMiddleware)();

        // adminGroup.withMiddleware!(AuthMiddleware)();
        // adminGroup.get("index.test").withoutMiddleware!(AuthMiddleware)();

        adminGroup.withMiddleware(AuthMiddleware.stringof);
        adminGroup.get("index.test").withoutMiddleware(AuthMiddleware.stringof);

        //
        ApplicationConfig appConfig = app.config();
        trace(appConfig.grpc.server.host);
        trace(appConfig.grpc.clientChannels.length);

        foreach(ref GrpcClientConf conf; appConfig.grpc.clientChannels) {
            info(conf.name);
        }

        app.logger().tracef("args: %s", "test");
        filebeatLogger().tracef("args: %s", "just another test");

    });

	app.run(args);
}

import std.digest.sha;

string getSalt(string name, string password) {
    string userSalt = name;
    auto sha256 = new SHA256Digest();
    ubyte[] hash256 = sha256.digest(password~userSalt);
    return toHexString(hash256);        
}


void testJwt() {
    
    string username = "admin";
    string password = "admin";

    string salt = getSalt(username, password);
    // string jwtToken = JwtUtil.sign(username, salt);
    // trace(jwtToken);
    // info(salt);

    string jwtToken = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1OTMzMTEzODgsImlhdCI6MTU5Mjg3OTM4OCwidXNlcm5hbWUiOiJhZG1pbiJ9.Csw9Ry6BI9vxiEEom4xt_nCtzYWjGPJIi5N2mS4Hbl2qhRwjBHlvjVTw81HGEJAS5tNBNxVpGnQKnHNTRIz2zA";

    bool v = JwtUtil.verify(jwtToken, username, salt);

    writeln(v);

}

void testConsole(string[] args) {
    Console console = new Console("Hunt Example", "3.0.0");

    console.setAutoExit(false);
    console.add(new ServeCommand());

    console.run(args);
}

// void testI18n() {
	
//     import hunt.framework.i18n.I18n;
// 	I18n i18n = new I18n();
// 	i18n.loadLangResources("./resources/translations");
// 	i18n.defaultLocale = "en-us";
// 	writeln(i18n.resources);
	
	
// 	///
// 	setLocale("en-br");
// 	assert( trans("hello-world") == "Hello, world");
	
// 	///
// 	setLocale("zh-cn");
// 	assert( trans("email.subject") == "收件人");
	
	
// 	setLocale("en-us");
// 	assert(trans("email.subject") == "email.subject");

//     // assert(trans("title") == "%s Demo");
//     assert(trans("title", "Hunt") == "Hunt Demo");

//     assert(transWithLocale("zh-cn", "title", "Hunt") == "Hunt 示例");
// }