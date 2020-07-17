module app.controller.api.IndexController;

import hunt.logging;
import hunt.framework;

import app.model.Greeting;
import std.datetime;

class IndexController : RestController {
	mixin MakeController;

	@Action string index() {
        return "API index.";
    }

	@Action string test() {
        return "API test.";
    }

    @Action Greeting showObject() {
        Greeting g = new Greeting();
        g.content = "Wellcome Hunt!";
        g.creationTime = Clock.currTime;
        g.currentTime = Clock.currStdTime;
        
        return g;
    } 
}