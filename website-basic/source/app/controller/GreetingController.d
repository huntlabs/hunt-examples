module app.controller.GreetingController;

import hunt.framework.websocket.WebSocketController;
import hunt.framework.messaging.annotation;

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

    alias ReturnHandler = void delegate(Object, TypeInfo);
    void __invoke(string methodName, MessageBase message, ReturnHandler handler ) {
        switch(methodName) {
            case "greeting" : {
                string r = greeting("message");
                // if(handler !is null) 
                //     handler(r, typeid(string));
                break;
            }

            default : {

            }
        }
    }

}