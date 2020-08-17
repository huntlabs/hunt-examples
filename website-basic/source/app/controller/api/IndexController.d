module app.controller.api.IndexController;

import hunt.logging.ConsoleLogger;
import hunt.framework;

import app.model.Greeting;
import std.datetime;

class IndexController : RestController {
	mixin MakeController;

	@Action string index() {
        return "API index.";
    }

	@Action string test() {

        // https://api.example.com/test/ 
        warning("index.test url: ", url("index.test", null, request().routeGroup()));

        return "API test.";
    }
    
    @Action string secret() {
        return "It's a secret page in admin.";
    }

    @Action Greeting showObject() {
        Greeting g = new Greeting();
        g.content = "Wellcome Hunt!";
        g.creationTime = Clock.currTime;
        g.currentTime = Clock.currStdTime;
        
        return g;
    } 
}