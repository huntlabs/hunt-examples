module app.controller.GreetingController;

import app.model.HelloMessage;
import app.model.Greeting;

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
    Greeting greeting(HelloMessage message) {
        Greeting gt = new Greeting();
        gt.content = "Hello, " ~ message.name ~ "!";
        gt.creationTime = creationTime;
        gt.currentTime = Clock.currStdTime;
        return gt; 
    }

    string greeting1(string message) {
        return "Hello " ~ message ~ "! CreationTime: " ~ creationTime.toString() ~ 
            " CurrentTime:" ~ Clock.currTime.toString();
    }

    string greeting2(string message) {

        return "Hello " ~ message ~ "! CreationTime: " ~ creationTime.toString() ~ 
            " CurrentTime:" ~ Clock.currTime.toString();
    }

    /**
     * generated on compile-time
     */
    import hunt.framework.messaging.Message;
    import hunt.framework.messaging.converter.AbstractMessageConverter;
    import hunt.framework.messaging.converter.MessageConverter;
    import hunt.framework.messaging.converter.MessageConverterHelper;
    import hunt.http.codec.http.model.MimeTypes;
    import hunt.lang.Nullable;
    import hunt.logging;
    import hunt.util.serialize;
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
                    warningf("Wrong pyaload type: %s, handler: %s", typeid(ob), methodName);
                    return;
                }

                JSONValue parametersInJson = temp.value;
                HelloMessage parameterModel = toObject!(HelloMessage)(parametersInJson);
                string str = parameterModel.name;
                version(HUNT_DEBUG) tracef("incoming message: %s", str);

                auto r = greeting(parameterModel);

                if(handler !is null) {
                    JSONValue resultInJson = toJson(r);
                    string resultInString = resultInJson.toString();
                    version(HUNT_DEBUG) tracef("outgoing message: %s", resultInString);
                    handler(new Nullable!string(resultInString), typeid(string));  
                }          

                break;
            }

            default : {
                version(HUNT_DEBUG) warning("do nothing for invoking " ~ methodName);
            }
        }
    }

}