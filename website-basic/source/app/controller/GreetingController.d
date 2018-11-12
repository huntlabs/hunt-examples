module app.controller.GreetingController;

import hunt.framework.websocket.WebSocketController;
import hunt.framework.messaging.annotation;

import hunt.logging;

import std.datetime;

class GreetingController : WebSocketController {

    SysTime creationTime;
    
    this() {
        creationTime = Clock.currTime;
    }

    @MessageMapping(["/hello"])
    @SendTo(["/topic/greetings"])
    string greeting(string message) {

        return "Hello " ~ message ~ "! CreationTime: " ~ creationTime.toString() ~ 
            " CurrentTime:" ~ Clock.currTime.toString();
        // Thread.sleep(1000); // simulated delay
        // return new Greeting("Hello, " + HtmlUtils.htmlEscape(message.getName()) + 
        // "! CreationTime: " + creationTime + " CurrentTime:" + System.currentTimeMillis());
    }

    import hunt.framework.messaging.Message;
    import hunt.lang.Nullable;

    shared static this() {
        WebSocketControllerHelper.registerController!GreetingController();
    }

    
    override protected void __invoke(string methodName, MessageBase message, ReturnHandler handler ) {
        version(HUNT_DEBUG) info("invoking: ", methodName);
        switch(methodName) {
            case "greeting" : {
                string r = greeting("message");
                if(handler !is null) 
                    handler(new Nullable!string(r), typeid(string));
                break;
            }

            default : {
                version(HUNT_DEBUG) warning("do nothing for " ~ methodName);
            }
        }
    }

}