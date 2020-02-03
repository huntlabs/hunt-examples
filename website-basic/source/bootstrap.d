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


import hunt.console;
import hunt.framework;
import hunt.logging;

import std.datetime;
import std.stdio;
import std.functional;

// import hunt.entity;

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


    // Console console = new Console("Hunt Example", "3.0.0");

    // console.setAutoExit(false);
    // console.add(new ServeCommand());

    // console.run(args);

    // example 3
    Application app = Application.instance();
    // app.enableLocale("./resources/translations");

    // writeln(trans("title"));
    // writeln(trans("title%s"));
    // writeln(transf("title", "Hunt"));

    // writeln(transWithLocale("zh-cn", "title"));
    // writeln(transWithLocale("zh-cn", "title", "Hunt"));
    app.onBreadcrumbsInitializing((BreadcrumbsManager breadcrumbs) {

        // breadcrumbs.register("home", delegate void (Breadcrumbs trail, Object[] params...) {
        //     trail.push("Home", "/home");
        // });

        breadcrumbs.register("home", (Breadcrumbs trail, Object[] params...) {
            trail.push("Home", "/home");
        });

// TODO: Tasks pending completion -@zhangxueping at 2020-01-02T18:45:03+08:00
// 
        // breadcrumbs.register("index.show", (Breadcrumbs trail, Object[] params...) {
        //     trail.parent("home");
        //     trail.push("About", url("index.show"));
        // });

        breadcrumbs.register("blog", (Breadcrumbs trail, Object[] params...) {
            trail.parent("home");
            trail.push("Blog", "/blog");
        });

        breadcrumbs.register("category", (Breadcrumbs trail, Object[] params...) {
            trail.parent("blog");
            trail.push("Category", "/blog/category");
        });

        // string s = breadcrumbs.render("index.show", null) ;
        // writeln(s);
        // s = breadcrumbs.render("category", null) ;
        // writeln(s);
    });

	app.run(args);
}


void testI18n() {
	
    import hunt.framework.i18n.I18n;
	I18n i18n = I18n.instance();
	i18n.loadLangResources("./resources/translations");
	i18n.defaultLocale = "en-us";
	writeln(i18n.resources);
	
	
	///
	setLocale("en-br");
	assert( trans("hello-world") == "Hello, world");
	
	///
	setLocale("zh-cn");
	assert( trans("email.subject") == "收件人");
	
	
	setLocale("en-us");
	assert(trans("email.subject") == "email.subject");

    // assert(trans("title") == "%s Demo");
    assert(trans("title", "Hunt") == "Hunt Demo");

    assert(transWithLocale("zh-cn", "title", "Hunt") == "Hunt 示例");
}