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

import std.stdio;
import std.functional;

import hunt.framework;
import std.datetime;

import hunt.framework.websocket.config.annotation.StompEndpointRegistry;
import hunt.stomp.simp.config.MessageBrokerRegistry;


void main()
{
	// Application app = Application.getInstance();
	// app.webSocket("/ws")
    // .onConnect((conn) {
    //     conn.sendText("Current time: " ~ Clock.currTime.toString());
    // })
    // .onText((text, conn) { 
    //     writeln("The server received: " ~ text); 
    //     conn.sendText(Clock.currTime.toString() ~ ": " ~ text);
    // }).start();

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

    Application app = Application.getInstance();
    app.enableLocale("./resources/lang");
    app.onBreadcrumbsInitializing((BreadcrumbsManager breadcrumbs) {

        // breadcrumbs.register("home", delegate void (BreadcrumbsGenerator trail, Object[] params...) {
        //     trail.push("Home", "/home");
        // });

        breadcrumbs.register("home", (BreadcrumbsGenerator trail, Object[] params...) {
            trail.push("Home", "/home");
        });

        breadcrumbs.register("index.show", (BreadcrumbsGenerator trail, Object[] params...) {
            trail.parent("home");
            trail.push("About", createUrl("index.show", null));
        });

        breadcrumbs.register("blog", (BreadcrumbsGenerator trail, Object[] params...) {
            trail.parent("home");
            trail.push("Blog", "/blog");
        });

        breadcrumbs.register("category", (BreadcrumbsGenerator trail, Object[] params...) {
            trail.parent("blog");
            trail.push("Category", "/blog/category");
        });

        string s = breadcrumbs.render("index.show", null) ;
        writeln(s);
        s = breadcrumbs.render("category", null) ;
        writeln(s);
    });

	app.withStompBroker().onConfiguration((MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    })
    .onStompEndpointsRegister((StompEndpointRegistry registry) {
        // https://blog.csdn.net/a617137379/article/details/78765025?utm_source=blogxgwz6
        // https://github.com/rstoyanchev/spring-websocket-portfolio/issues/14
        registry.addEndpoint("/gs-guide-websocket").setAllowedOrigins("*");
    })
    .start();


    

}
