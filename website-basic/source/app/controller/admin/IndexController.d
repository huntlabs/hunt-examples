module app.controller.admin.IndexController;

import hunt.logging;
import hunt.framework.application;
import hunt.framework.http;
import hunt.framework.view;

class IndexController : Controller {
	mixin MakeController;


	@Action string index() {
        return "Admin index.";
    }

	@Action string test() {
        return "Admin test.";
    }
}