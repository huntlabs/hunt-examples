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

import hunt.stomp.simp.config.MessageBrokerRegistry;
import hunt.framework.websocket.config.annotation.StompEndpointRegistry;


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


    Application app = Application.getInstance();
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
