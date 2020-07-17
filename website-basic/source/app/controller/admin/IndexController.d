module app.controller.admin.IndexController;

import hunt.logging;
import hunt.framework;

class IndexController : Controller {
	mixin MakeController;


	@Action string index() {
        return "Admin index.";
    }

	@Action string test() {
        return "Admin test.";
    }

    @Action string security() {
        return "It's a security page in admin.";
    }
       
}