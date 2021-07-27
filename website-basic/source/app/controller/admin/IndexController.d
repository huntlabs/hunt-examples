module app.controller.admin.IndexController;

import hunt.logging;
import hunt.framework;

class IndexController : Controller {
	mixin MakeController;


	@Action string index() {
        return "Admin index.";
    }

	@Action string test() {
        warning("xxxx=>", this.request.actionId);
        return "Admin test.";
    }

    @Action string secret() {
        return "It's a secret page in admin.";
    }
       
}