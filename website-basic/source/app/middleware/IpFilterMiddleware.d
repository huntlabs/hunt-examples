module app.middleware.IpFilterMiddleware;

import hunt.framework;
import hunt.logging.ConsoleLogger;

class IpFilterMiddleware : AbstractMiddleware!(IpFilterMiddleware) {

    Response onProcess(Request req, Response res) {
        // writeln(req.session());
        string path = req.path();
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
