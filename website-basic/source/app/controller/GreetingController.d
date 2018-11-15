module app.controller.GreetingController;

import app.model.HelloMessage;
import app.model.Greeting;

import hunt.framework.websocket.WebSocketController;
import hunt.stomp.annotation;

import hunt.logging;

import std.datetime;
import std.json;

class GreetingController : WebSocketController {

    /**
     * generated on compile-time
     */
    mixin ControllerExtensions;

    // BUG: Reported defects -@zxp at 11/15/2018, 10:23:57 AM
    // See also: https://forum.dlang.org/post/mailman.4142.1538654511.29801.digitalmars-d-learn@puremagic.com
    // private SysTime creationTime;
    SysTime creationTime;
    
    this() {
        super();
    }

    override void initialization() {
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
    // string greeting(HelloMessage message) {
    //     Greeting gt = new Greeting();
    //     gt.content = "Hello, " ~ message.name ~ "!";
    //     gt.creationTime = creationTime;
    //     gt.currentTime = Clock.currStdTime;
    //     return gt.toString(); 
    // }
    // int greeting(HelloMessage message) {
    //     Greeting gt = new Greeting();
    //     gt.content = "Hello, " ~ message.name ~ "!";
    //     gt.creationTime = creationTime;
    //     gt.currentTime = Clock.currStdTime;
    //     return 2018; 
    // }

// TODO: Tasks pending completion -@zxp at 11/14/2018, 4:34:27 PM
// 
    // @MessageMapping(["/hello1"])
    // @SendTo(["/topic/greetings1"])
    // string greeting(string name) {
    // // Greeting greeting(ref JSONValue __body) {
    //     Greeting gt = new Greeting();
    //     gt.content = "Hello, " ~ name ~ "!";
    //     gt.creationTime = creationTime;
    //     gt.currentTime = Clock.currStdTime;
    //     return gt.toString(); 
    // }

    @MessageMapping(["/hello3"])
    @SendTo(["/topic/greetings3"])
    int greeting0(string name, ref const(JSONValue) __body, int age) {
        return age;
    }


    @MessageMapping(["/hello4"])
    @SendTo(["/topic/greetings4"])
    string greeting1(string name, HelloMessage message) {
        return "Hello " ~ name ~ "! CreationTime: " ~ creationTime.toString() ~ 
            " CurrentTime:" ~ Clock.currTime.toString();
    }

    @MessageMapping(["/hello5"])
    @SendTo(["/topic/greetings5"])
    void greetingVoid() {
        // return "Hello world! CreationTime: " ~ creationTime.toString() ~ 
        //     " CurrentTime:" ~ Clock.currTime.toString();
    }

    // import hunt.stomp.Message;
    // import hunt.stomp.converter.AbstractMessageConverter;
    // import hunt.stomp.converter.MessageConverter;
    // import hunt.stomp.converter.MessageConverterHelper;
    // import hunt.http.codec.http.model.MimeTypes;
    // import hunt.lang.Nullable;
    // import hunt.logging;
    // import hunt.util.serialize;
    // import std.json;
    
    // shared static this() {
    //     WebSocketControllerHelper.registerController!GreetingController();
    // }

    
    // override protected void __invoke(string methodName, MessageBase message, ReturnHandler handler ) {

    //     version(HUNT_DEBUG) info("invoking: ", methodName);
        
    //     MessageConverter messageConverter = 
    //         annotationHandler.getMessageConverter();

    //     // MimeType mt = messageConverter.getMimeType();
    //     // info(mt.toString());
            
    //     Object ob = messageConverter.fromMessage(message, typeid(JSONValue));
    //     if(ob is null)
    //         warning("no payload");
    //     else {
    //          version(HUNT_DEBUG) infof("playload: %s", typeid(ob));
    //     }

    //     switch(methodName) {
    //         case "greeting" : {
    //             // string str = MessageConverterHelper.fromMessage!string(message);
    //             // auto temp = cast(Nullable!string) ob;
    //             auto temp = cast(Nullable!JSONValue) ob;
    //             if(temp is null) {
    //                 warningf("Wrong pyaload type: %s, handler: %s", typeid(ob), methodName);
    //                 return;
    //             }

    //             JSONValue parametersInJson = temp.value;
    //             HelloMessage parameterModel = toObject!(HelloMessage)(parametersInJson);
    //             string str = parameterModel.name;
    //             version(HUNT_DEBUG) tracef("incoming message: %s", str);

    //             auto r = greeting(parameterModel);

    //             if(handler !is null) {
    //                 JSONValue resultInJson = toJson(r);
    //                 string resultInString = resultInJson.toString();
    //                 version(HUNT_DEBUG) tracef("outgoing message: %s", resultInString);
    //                 handler(new Nullable!string(resultInString), typeid(string));  
    //             }          

    //             break;
    //         }

    //         default : {
    //             version(HUNT_DEBUG) warning("do nothing for invoking " ~ methodName);
    //         }
    //     }
    // }

}