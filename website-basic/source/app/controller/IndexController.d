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

import hunt.framework.application;
import hunt.framework.http;
import hunt.framework.view;
import hunt.framework.queue;


import hunt.amqp.client;
import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.http.server;
import hunt.framework;
import hunt.logging;
// import hunt.redis;
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
import std.stdio;
import std.string;


version (USE_ENTITY) import app.model.index;
import app.model.ValidForm;

// class TestQueueJob : Job {
//     this(int a, int b) {
//         _a = a;
//         _b = b;
//     }

//     override void exec() {
//         logDebug("taskid : ", this.id, ", do job ", _a, " + ", _b, " = ", _a + _b);
//     }

// private:
//     int _a;
//     int _b;
// }

class IpFilterMiddleware : MiddlewareInterface {
    override string name() {
        return IpFilterMiddleware.stringof;
    }

    override Response onProcess(Request req, Response res) {
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



/**
 * 
 */
class IndexController : Controller {
    mixin MakeController;

    this() {
        this.addMiddleware(new IpFilterMiddleware());

        assert(serviceContainer.isRegistered!ApplicationConfig());
        assert(serviceContainer.isRegistered!BasicApplicationConfig());
        assert(!serviceContainer.isRegistered!BasicApplicationConfigBase());

        // BasicApplicationConfig appConfig = serviceContainer().resolve!(BasicApplicationConfig);
        // BasicApplicationConfig appConfig = cast(BasicApplicationConfig)config();
        // trace(appConfig.github.appid);

        // GithubConfig githubConfig = configManager().load!GithubConfig();
        // trace(githubConfig.accessTokenUrl);
    }

    override bool before() {
        logDebug("---running before----");

        if (toUpper(request.getMethod()) == HttpMethod.OPTIONS.asString())
            return false;
        return true;
    }

    override bool after() {
        logDebug("---running after----");
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
        
        // HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, view.render("home"));
        // this.response.setBody(hb);
        this.response.setContent(view.render("home"), MimeType.TEXT_HTML_VALUE);
    }

    @Action string about() {
        warning("index.about url: ", url("index.about") );
        return "Hunt examples 3.0";
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
    @Action string showString() {
        logDebug("---show string----");
        return "Hello world. ";
    }

    @Action bool showBool() {
        logDebug("---show bool----");
        return true;
    }

    @Action int showInt() {
        logDebug("---test Routing1----", this.request.get("id"));
        return 2018;
    }

// 	@Action string testTracing() {
// version(WITH_HUNT_TRACE) {
// 		import hunt.http.client;
// 		import hunt.trace;
// 		import std.range;

// 		ApplicationConfig conf = config();
        
            
// 		string url = "http://10.1.222.110:801/index.html";
// 		HttpClient client = new HttpClient();

// 		RequestBuilder requestBuilder = new RequestBuilder()
// 				.url(url)
// 				.localServiceName(conf.application.name);

// 		Tracer tracer = this.request.tracer;
// 		if(tracer !is null) {
// 			requestBuilder.withTracer(tracer);
// 		} else {
// 			info("No tracer found. Use the default instead.");
// 		}

// 		Request req = requestBuilder.build();
// 		Response response = client.newCall(req).execute();

// 		if (response !is null) {
// 			tracef("status code: %d", response.getStatus());
// 			// if(response.haveBody())
// 			//  trace(response.getBody().asString());
// 		} else {
// 			warning("no response");
// 		}

// 		return "traceid: " ~ tracer.root.traceId;
// } else {
// 		return "Trace is disabled.";
// }
        
// 	}

    @Action string testRouting2(int id) {
        logDebug("---test Routing2----", this.request.queries);
        // request.get("id");
        Appender!string sb;
        sb.put("The router parameter(id) is: ");
        sb.put(id.to!string);
        sb.put(". <br>");
        sb.put(" The query parameters are: ");
        sb.put(to!string(this.request.queries));
        return sb.data;
    }

    @Action Response testRedis() {
        // import hunt.redis.RedisCluster;
        // import hunt.redis.Redis;

        Redis r = Application.instance().redis(); // getRedis();
        // scope(exit) r.close();

		std.datetime.DateTime now = cast(std.datetime.DateTime)Clock.currTime ;
        r.set("hunt_demo_redis", "Hunt redis test, " ~ now.toSimpleString());
        string s = r.get("hunt_demo_redis");
        // trace(s);

        // HttpBody hb = HttpBody.create(MimeType.TEXT_HTML_VALUE, "Redis result: " ~ s ~ "<br/>");
        
        Response response = new Response();
        response.setContent("Redis result: " ~ s ~ "<br/>", MimeType.TEXT_HTML_VALUE);

        return response;
    }

    // @Action string testAmqp() {
    //     AmqpConnection conn = amqpConnection();

    //     logInfo("Connection succeeded");
    //     conn.createSender("my-queue", new class hunt.amqp.client.Handler!AmqpSender {
    //         void handle(AmqpSender sender)
    //         {
    //             if(sender is null)
    //             {
    //                 logWarning("Unable to create a sender");
    //                 return;
    //             }

    //             sender.send(AmqpMessage.create().withBody("hello world").build());
    //             trace("send completed");

    //             //for (int i = 0 ; i < 100; ++i)
    //             //{
    //             //  sender.send(AmqpMessage.create().withBody("hello world").build());
    //             //  logInfo("send complite");
    //             //}
    //         }
    //     });

    //     return "Ok";
    // }

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

		view.setTemplateExt(".txt");
		view.assign("model", data);
        
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
		RedirectResponse r = new RedirectResponse(this.request, "https://www.putao.com/");
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

    @Action Response pushQueue() {        

        std.datetime.DateTime dt = cast(std.datetime.DateTime)Clock.currTime();
        string message = format("Say hello at %s", dt.toSimpleString());

        AbstractQueue queue  = messageQueue();
        queue.push("my-queue", cast(ubyte[])message);

        Response response = new Response();
        response.setContent(message);
        return response;
    }

    @Action Response queryQueue() {

        // FIXME: Needing refactor or cleanup -@zhangxueping at 2020-04-07T11:20:43+08:00
        // More tests needed

        enum string ChannelName = "my-queue";
        FuturePromise!string promise = new FuturePromise!string();
        string registTime = hunt.util.DateTime.DateTime.getTimeAsGMT();
        
        AbstractQueue queue  = messageQueue();
        scope(exit) {
            queue.remove(ChannelName);
        }

        queue.addListener(ChannelName, (ubyte[] message) {
            string msg = cast(string)message;
            warningf("Received message: %s", msg);
            promise.succeeded(msg);
        });

        string resultContent;
        Response response = new Response();
        resultContent = format("Listener for channel %s registed at %s", ChannelName, registTime);

        try {
            string message = promise.get(25.seconds);

            resultContent ~= "<br>\nThe received message: " ~ message;
        } catch(Exception ex) {
            resultContent ~= "<br>\nThe error message: " ~ ex.msg;
        }

        resultContent ~= "<br>\nThe end time: " ~ hunt.util.DateTime.DateTime.getTimeAsGMT();

        response.setContent(resultContent);
        return response;
    }

	// @Action Response createTask() {
	// 	string value1 = request.get("value1", "1");
	// 	string value2 = request.get("value2", "2");

	// 	auto t1 = new TestQueueJob(to!int(value1), to!int(value2));

	// 	queueWorker().push("test", t1);

	// 	Response response = new Response();
	// 	response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");
	// 	// response.setContent("the task id : " ~ to!string(t1.id()));
	// 	return response;
	// }

	// @Action Response stopTask() {
	// 	string taskid = request.get("taskid");
	// 	Response response = new Response(this.request);

	// 	if (taskid.empty()) {
	// 		response.setContent("The task id is empty!");
	// 	} else {
	// 		auto ok = taskManager.del(to!size_t(taskid));
	// 		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8");
	// 		response.setContent("stop task (" ~ taskid ~ ") : " ~ to!string(ok));

	// 	}
	// 	return response;
	// }


// 	@Action Response testPost() {

// 		Response response = new Response(this.request);
// 		import std.conv;

// 		Appender!string stringBuilder;
// 		stringBuilder.put("<p>Content:<p/>");
// 		stringBuilder.put(" MIME Type: " ~ this.request.header(HttpHeader.CONTENT_TYPE) ~ "<br/>");
// 		stringBuilder.put(" Length: " ~ this.request.header(HttpHeader.CONTENT_LENGTH) ~ "<br/>");

// 		stringBuilder.put("body content: <br/>");
// 		stringBuilder.put( this.request.getBodyAsString() ~ "<br/>");

// 		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
// 		response.setContent(stringBuilder.data);

// 		return response;		
// 	}

// 	@Action Response testForm1() {
// 		Response response = new Response(this.request);
// 		import std.conv;

// 		Appender!string stringBuilder;
// 		stringBuilder.put("<p>Form data from xFormData:<p/>");
// 		foreach (string key, string[] values; this.request.xFormData()) {
// 			stringBuilder.put(" name: " ~ key ~ ", value: " ~ values.to!string() ~ "<br/>");
// 		}

// 		stringBuilder.put("<p>Form data from post:<p/>");
// 		foreach (string key, string[] values; this.request.xFormData()) {
// 			stringBuilder.put(" name: " ~ key ~ ", value: " ~ this.request.post(key) ~ "<br/>");
// 		}

// 		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
// 		response.setContent(stringBuilder.data);

// 		return response;
// 	}

// 	@Action Response testUpload() {
// 		Response response = new Response(this.request);
// 		import std.conv;
// 		import hunt.framework.file.UploadedFile;

// 		Appender!string stringBuilder;

// 		stringBuilder.put("<br/>Uploaded files:<br/>");
// 		import hunt.http.codec.http.model.MultipartFormInputStream;
// 		import std.format;
// 		import hunt.text.StringUtils;

// 		foreach (UploadedFile p; request.allFiles()) {
// 			// string content = cast(string) mp.getBytes();
// 			p.move("Multipart file - " ~ StringUtils.randomId());
// 			stringBuilder.put(format("File: fileName=%s, actualFile=%s<br/>",
// 					p.originalName(), p.path()));
// 			// stringBuilder.put("<br/>content:" ~ content);
// 			stringBuilder.put("<br/><br/>");
// 		}

// 		foreach (string key, string[] values; request.xFormData) {
// 			stringBuilder.put(format("Form data: key=%s, value=%s<br/>",
// 					 key, values));
// 			stringBuilder.put("<br/><br/>");
// 		}

// 		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
// 		response.setContent(stringBuilder.data);

// 		return response;
// 	}

// 	@Action Response testValidForm(User user) {

// 		warning(request.post("name"));

// 		auto result = user.valid();
// 		logDebug(format("user(name = %s, age = %s, email = %s, friends = %s) ,isValid : %s , valid result : %s ",
// 				user.name, user.age, user.email, user.friends, result.isValid, result.messages()));
// 		Response response = new Response(this.request);

// 		Appender!string stringBuilder;
// 		stringBuilder.put("<p>Form data:<p/>");
// 		foreach (string key, string[] values; this.request.xFormData()) {
// 			stringBuilder.put(" name: " ~ key ~ ", value: " ~ values.to!string() ~ "<br/>");
// 		}

// 		stringBuilder.put("<br/>");
// 		stringBuilder.put("validation result:<br/>");
// 		stringBuilder.put(format("isValid : %s , valid result : %s<br/>",
// 				result.isValid, result.messages()));

// 		response.setHeader(HttpHeader.CONTENT_TYPE, MimeType.TEXT_HTML_UTF_8.asString());
// 		response.setContent(stringBuilder.data);

// 		return response;
// 	}

// 	@Action Response testMultitrans() {
// 		logDebug("url : ", request.url);
// 		Cookie cookie;
// 		Response response = new Response(this.request);
// 		if (request.url == "/zh") {
// 			cookie = new Cookie("Content-Language", "zh-cn");
// 			view.setLocale("zh-cn");
// 		} else {
// 			cookie = new Cookie("Content-Language", "en-us");
// 			view.setLocale("en-us");
// 		}

// 		response.setHeader(HttpHeader.CONTENT_TYPE, "text/html;charset=utf-8").withCookie(cookie);

// 		JSONValue model;
// 		import hunt.util.DateTime;

// 		model["stamp"] = time();
// 		model["now"] = Clock.currTime.toString();
// 		view.setTemplateExt(".dhtml");
// 		view.assign("model", model);
// 		view.assign("app",parseJSON(`{"name":"hunt"}`));
// 		view.assign("breadcrumbs", breadcrumbsManager.generate("home"));
// 		return response.setContent(view.render("home"));

// 	}
}
