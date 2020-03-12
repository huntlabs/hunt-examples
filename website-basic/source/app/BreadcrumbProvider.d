module app.BreadcrumbProvider;

import hunt.framework.provider.ServiceProvider;
import hunt.framework.provider.BreadcrumbServiceProvider;
import hunt.framework.application;

import hunt.logging.ConsoleLogger;

/**
 * 
 */
class BreadcrumbProvider : BreadcrumbServiceProvider {

    override void boot() {

        // breadcrumbs.register("home", delegate void (Breadcrumbs trail, Object[] params...) {
        //     trail.push("Home", "/home");
        // });

        breadcrumbs.register("home", (Breadcrumbs trail, Object[] params...) {
            trail.push("Home", "/home");
        });

        breadcrumbs.register("index.about", (Breadcrumbs trail, Object[] params...) {
            trail.parent("home");
            trail.push("About", url("index.about"));
        });
        
        // breadcrumbs.register("index.show", (Breadcrumbs trail, Object[] params...) {
        //     trail.parent("home");
        //     trail.push("About", url("index.show"));
        // });

        breadcrumbs.register("blog", (Breadcrumbs trail, Object[] params...) {
            trail.parent("home");
            trail.push("Blog", "/blog");
        });

        breadcrumbs.register("category", (Breadcrumbs trail, Object[] params...) {
            trail.parent("blog");
            trail.push("Category", "/blog/category");
        });

        // string s = breadcrumbs.render("index.show", null) ;
        // trace(s);

        // s = breadcrumbs.render("category", null) ;
        // trace(s);        
    }
}