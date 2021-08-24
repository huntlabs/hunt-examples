/*
 * Hunt - Hunt is a high-level D Programming Language Web framework that encourages rapid development and clean, pragmatic design. It lets you build high-performance Web applications quickly and easily.
 *
 * Copyright (C) 2015-2016  Shanghai Putao Technology Co., Ltd 
 *
 * Developer: putao's Dlang team
 *
 * Licensed under the BSD License.
 *
 */
module app.controller.IndexController;

import app.config;
import app.middleware;
import app.form.LoginUser;

import hunt.framework;
import hunt.shiro;

import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.http.server;
import hunt.framework;
import hunt.logging;
import hunt.redis.RedisCluster;
import hunt.redis.Redis;
import hunt.redis.RedisPool;
import hunt.util.DateTime;
import hunt.validation;

import core.time;

import std.conv;
import std.array;
import std.datetime;
import std.format;
import std.json;
// import std.meta;
import std.stdio;
import std.string;
import std.traits;


import hunt.concurrency.Executors;
import hunt.concurrency.Scheduler;
import hunt.concurrency.ScheduledThreadPoolExecutor;


version (USE_ENTITY) import app.model.index;
import app.model.ValidForm;

import app.model.Greeting;
import app.model.UserInfo;


enum string QueueChannelName = "my-queue";

/**
 * 
 */
// class IndexController : ControllerBase!(IndexController) {
class IndexController : Controller {
    mixin MakeController;

    this() {
        // this.addMiddleware(new IpFilterMiddleware());

        //tracef(url("index.login"));
        // tracef(url("index.checkAuth")); // /checkAuth/
        // warningf(url("index.test", null, "admin")); // /checkAuth/

        // AuthOptions options = new AuthOptions();
        // options.tokenCookieName = ADMIN_JWT_TOKEN_NAME;
        // options.scheme = AuthenticationScheme.Bearer;
        // options.guardName = ADMIN_GUARD_NAME;
        
        // this.authOptions = options;        

        // this.addMiddleware(new AuthMiddleware(&checkRoute, null));
        // this.addMiddleware(new JwtAuthMiddleware(&checkRoute));

        assert(serviceContainer.isRegistered!ApplicationConfig());
        assert(serviceContainer.isRegistered!BasicApplicationConfig());
        assert(!serviceContainer.isRegistered!BasicApplicationConfigBase());

        // BasicApplicationConfig appConfig = serviceContainer().resolve!(BasicApplicationConfig);
        // BasicApplicationConfig appConfig = cast(BasicApplicationConfig)config();
        // trace(appConfig.github.appid);

        // GithubConfig githubConfig = configManager().load!GithubConfig();
        // warning(githubConfig.accessTokenUrl);

        // AppConfig githubConfig = configManager().load!AppConfig();
        // trace(githubConfig.qimen.url);

        
        Application app = Application.instance;
        string filename = filebeatLogger().conf.fileName;
        filebeatLogger().tracef("controller: ", typeof(this).stringof);

        HostEnvironment env = app.environment;
        string str = format("Environment: %s, isDevelopment: %s", env.name, env.isDevelopment());
        warning(str);
    }
    

    private bool checkRoute(string path, string method) {

        warningf("Checking path: %s, method: %s", path, method);

        if(path[$-1] != '/')
            path ~= "/";

        string[] anonymousPaths = [url("index.login")]; // All the paths can be visited by everyone

        foreach(string p; anonymousPaths) {
            if(path.startsWith(p)) // skipping
                return false;
        }

        return true;
    }

    override bool before() {
        // logDebug("---running before----");

        if (toUpper(request.getMethod()) == HttpMethod.OPTIONS.asString())
            return false;
        return true;
    }

    override bool after() {
        // logDebug("---running after----");
        return true;
    }

    @Action 
    void index() {
        BreadcrumbItem[] items = Application.instance().breadcrumbs.generate("home");
        trace(items);

        JSONValue model;
        model["title"] = "Hunt demo";
        model["stamp"] = time();
        model["now"] = Clock.currTime.toString();
        view.setTemplateExt(".dhtml");
        view.assign("model", model);
        view.assign("app", parseJSON(`{"name":"Hunt"}`));
        view.assign("breadcrumbs", Application.instance().breadcrumbs.generate("home"));

        ulong a = 1;
		view.assign("a", a);
        
        // HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, view.render("home"));
        // this.response.setBody(hb);
        this.response.setContent(view.render("home"), MimeType.TEXT_HTML_VALUE);
    }

    @Middleware(IpFilterMiddleware.stringof)
    @Action string about() {
        warning("index.about url: ", url("index.about") );
        infof("action id: %s", this.request().actionId());

        import hunt.util.worker;
        import hunt.util.TaskPool;
        import hunt.net.NetServer;
        import hunt.event.EventLoopGroup;

        HttpServer httpServer = serviceContainer.resolve!(HttpServer);
        NetServer netServer = httpServer.netServer();
        EventLoopGroup loopGroup = netServer.eventLoopGroup();
        // TaskPool worker = loopGroup.worker();
        // worker.checkStatus();

        // string data = `"abc`;

        // try {
        //     JSONValue jv = parseJSON(data);
        // } catch(Throwable e) {
        //     warning(e.msg);
        //     warning(e);
        // }



        return "Hunt examples 3.0";
    }
    
    @Middleware(IpFilterMiddleware.stringof)
    @Middleware(AuthMiddleware.stringof)
    @Action string secret() {
        return "OK. It's a secret page.";
    }

    @WithoutMiddleware(AuthMiddleware.stringof)
    @Action string checkAuth() {
        // Subject currentUser = SecurityUtils.getSubject();
        // string content = format("Auth status: %s, who: %s", currentUser.isAuthenticated, currentUser.getPrincipal());
        Identity currentUser = this.request.auth().user();
        string content = format("Auth status: %s, who: %s", currentUser.isAuthenticated, currentUser.name);
        return content;
    }

    @WithoutMiddleware(AuthMiddleware.stringof)
    @Action Response login(LoginUser user) {

        string username = user.name;
        string password = user.password;
        bool rememeber = user.rememeber;

        import app.data.HuntUserService;

        // UserService us = new HuntUserService();
        // string salt = us.getSalt(username, password);

        Identity authUser = this.request.auth().signIn(username, password, rememeber);
        
        string msg;
        if(authUser.isAuthenticated()) {
            msg = "User [" ~ authUser.name ~ "] logged in successfully.";
            info(msg);

            if (authUser.hasRole("admin")) {
                msg ~= "<br/>Welcome Administrator!";
                trace("Administrator logged");
            }

            
            if (authUser.hasAllRoles("admin", "manager")) {
                // The user has all the roles
            }

            if(authUser.isPermitted(["user.add", "user.del"])) {
                // The user is isPermitted
            }

        } else {
            msg = "Login failed!";
        }

        return new Response(msg);
    }

    @Action string logout() {

        Identity currentUser = this.request.auth().user();
        if(currentUser.isAuthenticated()) {
            string name = currentUser.name();
            this.request().auth().signOut();
            return "The user [" ~ name ~ "] has logged out.";
        } else {
            return "No user logged in.";
        }
    }

    @Action string resusage() {
        import resusage;

        enum ulong M = 1024*1024;
        Appender!string sb;

        sb.put("<b>[The system memory usage]</b>" ~ "<br/>\n");

        SystemMemInfo sysMemInfo = systemMemInfo(); 
        string text = format("<b>totalRAM</b>: %10d M<br/>\n" ~ 
            "<b>usedRAM</b>: %10d M<br/>\n" ~ 
            "<b>freeRAM</b>: %10d M<br/>\n", 
            sysMemInfo.totalRAM/M, sysMemInfo.usedRAM/M, sysMemInfo.freeRAM/M);
        sb.put(text);
        sb.put("<br/>\n");

        text = format("<b>totalVirtMem</b>: %10d M<br/>\n" ~ 
                "<b>usedVirtMem</b>: %10d M<br/>\n" ~ 
                "<b>freeVirtMem</b>: %10d M", 
            sysMemInfo.totalVirtMem/M, sysMemInfo.usedVirtMem/M, sysMemInfo.freeVirtMem/M);
        sb.put(text);
        sb.put("<br/><br/>\n");
        

        sb.put("<b>[The memory usage of the current process]</b>" ~ "<br/>\n");
        ProcessMemInfo procMemInfo = processMemInfo();
        text = format("<b>Virtual memory used:</b> %10d M<br/>\n" ~ 
            "<b>Physical memory used:</b> %10d M<br/>\n", 
            procMemInfo.usedVirtMem/M, procMemInfo.usedRAM/M);
        sb.put(text);
        sb.put("<br/><br/>\n");

        
        sb.put("<b>[GC states]</b>" ~ "<br/>\n");

        import core.memory;
        GC.Stats  states = GC.stats();
        text = format("<b>usedSize</b>: %d bytes<br/>\n" ~ 
            "<b>freeSize</b>: %d bytes<br/>\n" ~ 
            "<b>allocatedInCurrentThread</b>: %d bytes<br/>\n", 
            states.usedSize, states.freeSize, states.allocatedInCurrentThread);
        sb.put(text);

        sb.put("<br/><br/>\n");

        
        sb.put("<b>[GC profileStates]</b>" ~ "<br/>\n");
        GC.ProfileStats profileStates = GC.profileStats();

        text = format("<b>numCollections:</b> %d<br/>\n" ~ 
                "<b>totalCollectionTime</b>: %s<br/>\n" ~ 
                "<b>totalPauseTime</b>: %s<br/>\n" ~ 
                "<b>maxPauseTime</b>: %s<br/>\n" ~ 
                "<b>maxCollectionTime</b>: %s <br/>\n", 
            profileStates.numCollections, profileStates.totalCollectionTime, 
            profileStates.totalPauseTime, profileStates.maxPauseTime, 
            profileStates.maxCollectionTime);
        sb.put(text);

        return sb.data; 
    }

    // Response showAction() {
    // 	logDebug("---show Action----");
        
    // 	HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, "Show message(No @Action defined): Hello world<br/>");

    // 	// dfmt off
    // 	response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8")
    // 		.header("X-Header-One", "Header Value")
    // 		.headers(["X-Header-Two":"Header Value", "X-Header-Tree": "Header Value"])
    // 		.setBody(hb);

    // 	// dfmt on
    // 	return response;
    // }

    Response test_action() {
        logDebug("---test_action----");
        // HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, "Show message: Hello world<br/>");
        // response.setBody(hb);

        response.setContent("Show message: Hello world<br/>", MimeType.TEXT_HTML_VALUE);

        return response;
    }

    @Action void showVoid()
    {
        logDebug("---show void----");
    }

// FIXME: Needing refactor or cleanup -@zhangxueping at 2019/9/20 下午11:59:05
// 
    // @Action string showString(error) {
    @Action string plaintext() {
        // logDebug("---show string----");

        filebeatLogger().tracef("args: %s", "just another test");

        warning(session().all);

        return "Hello world. ";
    }

    @Action bool showBool() {
        logDebug("---show bool----");
        return true;
    }

    @Action int showInt() {
        logDebug("---test Routing1----", this.request.get("id"));

        ulong t = this.request.get!ulong("id", 2);

        // string id = this.request.get("id");
        string id = this.request.id;
        if(!id.empty) {
            int v = id.to!int();
            infof("---test Routing1----%d", v);
            return v;
        } else {
            return 2020;
        }

    }

    @Action Greeting showObject() {
        Greeting g = new Greeting();
        g.content = "Wellcome Hunt!";
        g.creationTime = Clock.currTime;
        g.currentTime = Clock.currStdTime;
        
        return g;
    }

    @Action string testUDAs(@Range(1, 100) int number, @Length(3, 6) @AliasField("e-mail") string email) {
        ConstraintValidatorContext context = validate();
        if(context.isValid()) {
            return "Test passed";
        } else {
            return context.toString();
        }
    }

	@Action string testTracing() {
version(WITH_HUNT_TRACE) {
		import hunt.http.client;
		import hunt.trace;
		import std.range;

		ApplicationConfig conf = config();
        
		string url = "http://10.1.23.222/index.html";
		HttpClient client = new HttpClient();

		RequestBuilder requestBuilder = new RequestBuilder()
				.url(url)
				.localServiceName(conf.application.name ~ "-client");

		Tracer tracer = this.request.tracer;
		if(tracer !is null) {
			requestBuilder.withTracer(tracer);
		} else {
			info("No tracer found. Use the default instead.");
		}

		Request req = requestBuilder.build();
		Response response = client.newCall(req).execute();

		if (response !is null) {
			tracef("status code: %d", response.getStatus());
			// if(response.haveBody())
			//  trace(response.getBody().asString());
		} else {
			warning("no response");
		}

		return "traceid: " ~ tracer.root.traceId;
} else {
		return "Trace is disabled.";
}
	}

    @Action string testRouting2(int id) {
        logDebug("---test Routing2----", this.request.queries);
        
        infof("action id: %s", this.request().actionId());
        
        // request.get("id");
        Appender!string sb;
        sb.put("The router parameter(id) is: ");
        sb.put(id.to!string);
        sb.put(". <br/>");
        sb.put(" The query parameters are: ");
        sb.put(to!string(this.request.queries));
        return sb.data;
    }

    @Action Response testRedis() {
        // import hunt.redis.RedisCluster;
        // import hunt.redis.Redis;

        Redis r = Application.instance().redis(); 

		std.datetime.DateTime now = cast(std.datetime.DateTime)Clock.currTime ;
        r.set("hunt_demo_redis", "Test for redis, " ~ now.toSimpleString());
        string s = r.get("hunt_demo_redis");
        // trace(s);

        Response response = new Response();
        response.setContent("Redis result: " ~ s ~ "<br/>", MimeType.TEXT_HTML_VALUE);

        return response;
    }

    @Action Response testRedisCluster() {
        // import hunt.redis.RedisCluster;
        // import hunt.redis.Redis;

        RedisCluster r = Application.instance().redisCluster();

		std.datetime.DateTime now = cast(std.datetime.DateTime)Clock.currTime ;
        r.set("hunt_redis_cluster", "Test for RedisClust, " ~ now.toSimpleString());
        string s = r.get("hunt_redis_cluster");
        // trace(s);

        Response response = new Response();
        response.setContent("Redis result: " ~ s ~ "<br/>", MimeType.TEXT_HTML_VALUE);

        return response;
    }

    @Action Response setCookie() {
        logDebug("---test Cookie ----");
        Cookie cookie1 = new Cookie("name1", "value1", 1000);
        Cookie cookie2 = new Cookie("name2", "value2", 1200, "/path");
        Cookie cookie3 = new Cookie("name3", "value3", 4000);

        Appender!string sb;
        sb.put("Three cookies are set.<br/>");
        sb.put(cookie1.toString() ~ "<br/>");
        sb.put(cookie2.toString() ~ "<br/>");
        sb.put(cookie3.toString() ~ "<br/>");
        // HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, sb.data());

        // dfmt off
        Response response = new Response();

        response.withCookie(cookie1)
            .withCookie(cookie2)
            .withCookie(cookie3)
            .header("X-Header-One", "Header Value")
            .withHeaders(["X-Header-Two":"Header Value", "X-Header-Tree": "Header Value"])
            .withContent(sb.data(), MimeType.TEXT_HTML_VALUE);
        // dfmt on

        return response;
    }

    @Action Response getCookie() {

        Appender!string sb;

        Cookie[] cookies = this.request.getCookies();
        if (cookies.length > 0) {
            sb.put("Found cookies:<br/>");
            foreach (Cookie c; cookies) {
                sb.put(format("%s=%s<br/>", c.getName(), c.getValue()));
            }
        } else {
            sb.put("No cookie found.");
        }

        // auto response = new Response();
        response.withContent(sb.data, MimeType.TEXT_HTML_VALUE);
        return response;
    }

	@Action JSONValue testJson1() {
		logDebug("---test Json1----");
		JSONValue js;
		js["message"] = "Hello world.";
		return js;
	}

	@Action JsonResponse testJson2() {
		logDebug("---test Json2----");
		JSONValue company;
		company["name"] = "Putao";
		company["city"] = "Shanghai";

		JsonResponse res = new JsonResponse(company);
		return res;
	}

	@Action string showView() {
		JSONValue data;
		data["name"] = "Cree";
		data["alias"] = "Cree";
		data["city"] = "Christchurch";
		data["age"] = 3;
		data["age1"] = 28;
		data["addrs"] = ["ShangHai", "BeiJing"];
		data["is_happy"] = false;
		data["allow"] = false;
		data["users"] = ["name" : "jeck", "age" : "18"];
		data["nums"] = [3, 5, 2, 1];
		data["colors"] = "red, black, blue";

		view.setTemplateExt(".dhtml");
		view.assign("model", data);

        EntityManager entityManager = defaultEntityManager();

        string queryString = "select a from UserInfo a where a.id < :id";
        EqlQuery!(UserInfo) query = entityManager.createQuery!(UserInfo)(queryString);
        query.setParameter("id", 10);

        UserInfo[] allUsers = query.getResultList();
		view.assign("allUsers", allUsers);

        int a = 1;
		view.assign("a", a);
        
		return view.render("index");
	}

	@Action FileResponse testDownload() {
		string file = request.get("file", "putao.png");
		file = "attachments/" ~ file;
		FileResponse r = new FileResponse(file);
		return r;
	}

	@Action RedirectResponse testRedirect1() {
		HttpSession session = request.session(true);
		session.set("test", "for RedirectResponse");
        tracef("all sessions: %s", session.all);
		// RedirectResponse r = new RedirectResponse(this.request, "https://www.putao.com/");
        string newUrl = url("admin:index.test");
        RedirectResponse r = new RedirectResponse(this.request, newUrl).withSession("hunt", "somthing");

		return r;
	}

	@Action RedirectResponse testRedirect2() {
		RedirectResponse r = new RedirectResponse(this.request, "https://www.putao.com/");
		return r;
	}

	@Action Response setCache() {
		HttpSession session = request.session(true);
		std.datetime.DateTime now = cast(std.datetime.DateTime)Clock.currTime ;
		session.set("test", "current time: " ~ now.toSimpleString());

		string key = request.get("key");
		string value = request.get("value");
		Application.instance().cache.set(key, value);

		Appender!string stringBuilder;

		stringBuilder.put("Cache test: <br/>");
		stringBuilder.put("key : " ~ key ~ " value : " ~ value);
		stringBuilder.put("<br/><br/>Session Test: ");
		stringBuilder.put("<br/>SessionId: " ~ session.getId());
		stringBuilder.put("<br/>key: test, value: " ~ session.get("test"));

		// request.flush(); // Can be called automatically by Response.done.

		// Response response = new Response();
        
        // HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, stringBuilder.data);
        // return new Response(hb);

		response.setContent(stringBuilder.data);
		return response;
	}

	@Action Response getCache() {
		HttpSession session = request.session();

		string key = request.get("key");
		string value = Application.instance().cache.get!(string)(key);

		Appender!string stringBuilder;
		stringBuilder.put("Cache test:<br/>");
		stringBuilder.put(" key: " ~ key ~ ", value: " ~ value);

		if (session !is null) {
			string sessionValue = session.get("test");
			stringBuilder.put("<br/><br/>Session Test: ");
			stringBuilder.put("<br/>  SessionId: " ~ session.getId);
			stringBuilder.put("<br/>  key: test, value: " ~ sessionValue);
		}

        // HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, stringBuilder.data);
        // return new Response(hb);
		Response response = new Response();
		response.setContent(stringBuilder.data)
            .header(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_VALUE);

		return response;
	}


    @Action Response queryQueue() {

        // FIXME: Needing refactor or cleanup -@zhangxueping at 2020-04-07T11:20:43+08:00
        // More tests needed

        // FuturePromise!string promise = new FuturePromise!string();
        // string registTime = hunt.util.DateTime.DateTime.getTimeAsGMT();
        
        // AbstractQueue queue  = messageQueue();
        // scope(exit) {
        //     queue.remove(QueueChannelName);
        // }

        // queue.addListener(QueueChannelName, (ubyte[] message) {
        //     string msg = cast(string)message;
        //     warningf("Received message: %s", msg);
        //     promise.succeeded(msg);
        // });

        string resultContent;
        Response response = new Response();
        // resultContent = format("Listener for channel %s registed at %s", QueueChannelName, registTime);

        try {
            string message = ""; //promise.get(25.seconds);

            resultContent ~= "<br/>\nThe received message: " ~ message;
        } catch(Exception ex) {
            resultContent ~= "<br/>\nThe error message: " ~ ex.msg;
        }

        resultContent ~= "<br/>\nThe end time: " ~ hunt.util.DateTime.DateTime.getTimeAsGMT();

        response.setContent(resultContent);
        return response;
    }

    // @Action Response pushQueue() {        

    //     std.datetime.DateTime dt = cast(std.datetime.DateTime)Clock.currTime();
    //     string message = format("Say hello at %s", dt.toSimpleString());

    //     // AbstractQueue queue  = messageQueue();
    //     AbstractQueue queue  = Application.instance().queue();
    //     queue.push("my-queue", message);

    //     Response response = new Response();
    //     response.setContent(message);
    //     return response;
    // }


	@Action Response createTask() {
        import app.task.TestTask;
		string value1 = request.get("value1", "1");
		string value2 = request.get("value2", "2");

		TestTask t1 = new TestTask(to!int(value1), to!int(value2));

        Worker worker = Application.instance.task();
		worker.put(t1);

		Response response = new Response();
		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");
		response.setContent("the task id : " ~ to!string(t1.id));
		return response;
	}

	@Action Response stopTask() {
		string taskid = request.get("taskid");
		Response response = new Response();

		if (taskid.empty()) {
			response.setContent("The task id is empty!");
		} else {
			response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");

            size_t id = to!size_t(taskid);
            Worker worker = Application.instance.task();
            
            try {
                Task task = worker.get(id);
                task.stop();
                worker.remove(id);
			    response.setContent("task: " ~ task.toString());
            } catch(Exception ex) {
                response.setContent("Error: " ~ ex.msg);
            }
		}
		return response;
	}

	@Action Response checkTask() {
		string taskid = request.get("taskid");
		Response response = new Response();

		if (taskid.empty()) {
			response.setContent("The task id is empty!");
		} else {
			response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");

            size_t id = to!size_t(taskid);
            Worker worker = Application.instance.task();
            try {
                Task task = worker.get(id);
                response.setContent("task status: " ~ task.toString());
            } catch(Exception ex) {
                response.setContent("Error: " ~ ex.msg);
            }

		}
		return response;
	}

	@Action Response testPost() {

		Response response = new Response();
		import std.conv;

		Appender!string stringBuilder;
		stringBuilder.put("<p>Content:<p/>");
		stringBuilder.put(" MIME Type: " ~ this.request.header(HttpHeader.CONTENT_TYPE) ~ "<br/>");
		stringBuilder.put(" Length: " ~ this.request.header(HttpHeader.CONTENT_LENGTH) ~ "<br/>");

        warningf("name: %s", request.post("name"));
        warningf("names: %s", request.posts("name"));

		stringBuilder.put("body content: <br/>");
		stringBuilder.put( this.request.getBodyAsString() ~ "<br/>");

		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);

		return response;		
	}

    @Action
    string testGrpc() {
        string[string] queryParameters = request.queries();
        string channelName = "ch1";

        if("channel" in  queryParameters) {
            channelName = queryParameters["channel"];

            if(channelName != "ch1" && channelName != "ch2")
            return "Undefined channel: " ~ channelName;
        }

        // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-02-07T11:43:01+08:00
        // No exception thrown while connection failed.

        import grpc;
        import helloworld.helloworld;
        import helloworld.helloworldrpc;

        Application app = Application.instance();
        try {
            Channel channel = app.grpc.getChannel(channelName);
            scope(exit) {
                channel.destroy();
            }

            // FIXME: Needing refactor or cleanup -@zhangxueping at 2021-02-07T15:08:54+08:00
            // Not always successful

            GreeterClient client = new GreeterClient(channel);
            HelloRequest request = new HelloRequest();
            request.name = "Hunt";   

            HelloReply replyHello = client.SayHello(request);
            tracef("++++++++++++++++%s", replyHello.message);

            HelloReply replyBye = client.SayGoodBye(request);
            tracef("++++++++++++++++%s", replyBye.message);

            return channelName ~ " passed";
        } catch(Exception ex) {
            warning(ex);
            return ex.msg;
        }
    }

	@Action Response testForm1() {
		Response response = new Response();
		import std.conv;

		Appender!string stringBuilder;
		stringBuilder.put("<p>Form data from formData:<p/>");
		foreach (string key, string[] values; this.request.formData()) {
			stringBuilder.put(" name: " ~ key ~ ", value: " ~ values.to!string() ~ "<br/>");
		}

		stringBuilder.put("<p>Form data from post:<p/>");
		foreach (string key, string[] values; this.request.formData()) {
			stringBuilder.put(" name: " ~ key ~ ", value: " ~ this.request.post(key) ~ "<br/>");
		}

		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);

		return response;
	}

	@Action Response testUpload() {
		Response response = new Response();
		import std.conv;
		import hunt.framework.file.UploadedFile;

		Appender!string stringBuilder;

		stringBuilder.put("<br/>Uploaded files:<br/>");
		// import hunt.http.codec.http.model.MultipartFormInputStream;
		import std.format;
		import hunt.text.StringUtils;

		foreach (UploadedFile p; request.allFiles()) {
			// string content = cast(string) mp.getBytes();
            // FIXME: Needing refactor or cleanup -@zhangxueping at 2020-12-29T14:45:06+08:00
            // INSklmnrsv: Invalid cross-device link
			// p.move("Multipart file - " ~ StringUtils.randomId());
            
			stringBuilder.put(format("File: fileName=%s, actualFile=%s<br/>",
					p.originalName(), p.path()));
			// stringBuilder.put("<br/>content:" ~ content);
			stringBuilder.put("<br/><br/>");
		}

        string[string] d = request.all();

        foreach(string name, string value; d) {
            warningf("name: %s, value: %s", name, value);

			stringBuilder.put(format("Form data: key=%s, value=%s<br/>",
					 name, value));
        }

		// foreach (string key, string[] values; request.formData) {
        //     warningf("key: %s, values: %s", key, values);

		// 	stringBuilder.put(format("Form data: key=%s, value=%s<br/>",
		// 			 key, values));
		// 	stringBuilder.put("<br/><br/>");
		// }

		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);

		return response;
	}

	// @Action Response testValidForm(int id=12, string name="Alice") {
    @Action Response testValidForm(User user, int id=12, string name="Alice") {

		warningf("id: %s, name: %s, queryName: %s", id, request.post("name", "default post"), name);

		auto result = user.valid();
		logDebug(format("user(name = %s, age = %s, email = %s, friends = %s) ,isValid : %s , valid result : %s ",
				user.name, user.age, user.email, user.friends, result.isValid, result.messages()));
		Response response = new Response();

		Appender!string stringBuilder;
		stringBuilder.put("<p>Form data:<p/>");
		foreach (string key, string[] values; this.request.formData()) {
			stringBuilder.put(" name: " ~ key ~ ", value: " ~ values.to!string() ~ "<br/>");
		}

		stringBuilder.put("<br/>");
		stringBuilder.put("validation result:<br/>");
		stringBuilder.put(format("isValid : %s , valid result : %s<br/>",
				result.isValid, result.messages()));

		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
		response.setContent(stringBuilder.data);

		return response;
	}

	@Action Response testMultitrans() {
		logDebug("url : ", request.url);
		Cookie cookie;
		Response response = new Response();
		if (request.url == "/zh") {
			cookie = new Cookie("Content-Language", "zh-cn");
			view.setLocale("zh-cn");
		} else {
			cookie = new Cookie("Content-Language", "en-us");
			view.setLocale("en-us");
		}

		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8").withCookie(cookie);

		JSONValue model;
		import hunt.util.DateTime;

		model["stamp"] = time();
		model["now"] = Clock.currTime.toString();
		view.setTemplateExt(".dhtml");
		view.assign("model", model);
		view.assign("app",parseJSON(`{"name":"hunt"}`));
		view.assign("breadcrumbs", Application.instance.breadcrumbs.generate("home"));
		return response.setContent(view.render("home"));

	}

    @Action string startScheduler() {
        return "started";

    }

    @Action string checkScheduler() {
        return "checking";
    }


    @Action string stopScheduler() {
        if (executor !is null) {
            executor.shutdown();
        }

        return "";

    }

}


__gshared ScheduledThreadPoolExecutor executor;


// shared static ~this() {
//     stopScheduler();
// }
