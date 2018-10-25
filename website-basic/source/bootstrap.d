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


void main()
{
	Application app = Application.getInstance();
	app.webSocket("/ws")
    .onConnect((conn) {
        conn.sendText("Current time: " ~ Clock.currTime.toString());
    })
    .onText((text, conn) { 
        writeln("The server received: " ~ text); 
        conn.sendText(Clock.currTime.toString() ~ ": " ~ text);
    }).start();
}

