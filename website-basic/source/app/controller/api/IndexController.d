module app.controller.api.IndexController;

import hunt.logging;
import hunt.framework;


class IndexController : Controller {
	mixin MakeController;

	@Action string index() {
        return "API index.";
    }

	@Action string test() {
        return "API test.";
    }
}