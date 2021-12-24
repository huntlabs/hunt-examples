module app.middleware.IpFilterMiddleware;

import hunt.framework;
import hunt.logging;

class IpFilterMiddleware : AbstractMiddleware {

    shared static this() {
        MiddlewareInterface.register!(typeof(this));
    }

    Response onProcess(Request req, Response res) {
        // writeln(req.session());
        string path = req.path();

        infof("action id: %s", req.actionId());

        infof("path: %s, post name: %s", path, req.post("name"));
        // FIXME: Needing refactor or cleanup -@zhangxueping at 2020-01-06T14:37:41+08:00
        // 
        // if(path == "/redirect1") {
        // 	RedirectResponse r = new RedirectResponse(req, "https://www.putao.com/");
        // 	return r;
        // }
        return null;
    }
}
