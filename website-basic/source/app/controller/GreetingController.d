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
        // return new Greeting("Hello, " + HtmlUtils.htmlEscape(message.getName()) + 
        // "! CreationTime: " + creationTime + " CurrentTime:" + System.currentTimeMillis());
    }

    import hunt.framework.messaging.Message;
    import hunt.framework.messaging.converter.AbstractMessageConverter;
    import hunt.framework.messaging.converter.MessageConverter;
    import hunt.framework.messaging.converter.MessageConverterHelper;
    import hunt.http.codec.http.model.MimeTypes;
    import hunt.lang.Nullable;
    import hunt.logging;
    import std.json;
    
    shared static this() {
        WebSocketControllerHelper.registerController!GreetingController();
    }

    
    override protected void __invoke(string methodName, MessageBase message, ReturnHandler handler ) {

        version(HUNT_DEBUG) info("invoking: ", methodName);
        
        MessageConverter messageConverter = 
            annotationHandler.getMessageConverter();

        // MimeType mt = messageConverter.getMimeType();
        // info(mt.toString());
            
        Object ob = messageConverter.fromMessage(message, typeid(JSONValue));
        if(ob is null)
            warning("no payload");
        else {
             version(HUNT_DEBUG) infof("playload: %s", typeid(ob));
        }

        switch(methodName) {
            case "greeting" : {
                // string str = MessageConverterHelper.fromMessage!string(message);
                // auto temp = cast(Nullable!string) ob;
                auto temp = cast(Nullable!JSONValue) ob;
                if(temp is null) {
                    warningf("Wrong pyaload type: %s", typeid(ob));
                    return;
                }
                JSONValue jv = temp.value;
                string str = jv["name"].str;
                tracef("incoming message: %s", str);
                string r = greeting(str);
                tracef("outgoing message: %s", r);
                // messageConverter.toMessage(message, typeid(string));

                if(handler !is null) {

                    handler(new Nullable!string(r), typeid(string));  
                }          

                // string r = greeting(str);
                // if(handler !is null) 
                //     handler(new Nullable!string(r), typeid(string));
                break;
            }

            default : {
                version(HUNT_DEBUG) warning("do nothing for " ~ methodName);
            }
        }
    }

}