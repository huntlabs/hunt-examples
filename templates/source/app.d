import std.stdio;
import std.json;

import hunt.framework.view;

void main()
{
	auto Env = GetViewObject().env();
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
	data["nums"] = [3,5,2,1];
	data["time"] = 1529568495;
	
	JSONValue user1;
	user1["name"] = "cree";
	user1["age"] = 2;
	user1["hobby"] = ["eat", "drink"];
	JSONValue user2;
	user2["name"] = "jeck";
	user2["age"] = 28;
	user2["hobby"] = ["sing", "football"];
	JSONValue[] userinfo;
	userinfo ~= user1;
	userinfo ~= user2;
	JSONValue data2;
	data2["userinfo"] = userinfo;

	string input;
	writeln("------------------IF--------------------------");
	input="{% if is_happy %}happy{% else %}unhappy{% endif %}";
	writeln("result : ",Env.render(input, data));

	writeln("------------------FOR-------------------------");
	input = "{% for addr in addrs %}{{addr}} {% endfor %}";
	writeln("result : ",Env.render(input, data));

	writeln("------------------FOR2-------------------------");
	input = "<ul>{% for addr in addrs %}<li><a href=\"{{ addr }}\">{{ addr }}</a></li>{% endfor %}</ul>";
	writeln("result : ",Env.render(input, data));

	writeln("------------------MAP-------------------------");
	input = "{% for k,v in users %}{{ k }} -- {{ v }}  {% endfor %}";
	writeln("result : ",Env.render(input, data));

	writeln("------------------FUNC upper------------------");
	input = "{{ upper(city) }}";
	writeln("result : ",Env.render(input, data));

	writeln("----------------FUNC lower--------------------");
	input = "{{ lower(city) }}";
	writeln("result : ",Env.render(input, data));

	writeln("-------------FUNC compare operator------------");
	input = "{% if length(addrs)>=4 %}true{% else %}false{% endif %}";
	writeln("result : ",Env.render(input, data));

	writeln("-------------FUNC compare operator (string)------------");
	input = "{% if name != \"Peter\" %}true{% else %}false{% endif %}";
	writeln("result : ",Env.render(input, data));

	writeln("---------Render file with `include`-----------");
	writeln("result : ", Env.renderFile("index.txt", data));

	writeln("---------------Render file--------------------");
	writeln("result : ", Env.renderFile("main.txt", data));

	writeln("---------Render file with `include` & save to file-----------");
	Env.write("index.txt", data,"index.html");


	writeln("------------------Deep for-------------------------");
	input = "{% for user in userinfo %}{{user.hobby[1]}} {% endfor %}";
	writeln("result : ",Env.render(input, data2));

	writeln("------------------Deep for 2-------------------------");
	input = "{{userinfo[1].name}}";
	writeln("result : ",Env.render(input, data2));

	writeln("------------------Deep for-------------------------");
	input = "{% for user in userinfo %}{% for h in user.hobby %} {{ h }} {% endfor %}{% endfor %}";
	writeln("result : ",Env.render(input, data2));

	writeln("-------------FUNC  operator------------");
	input = "{{ 'a' <= '1' }} ~ {{ age >= age1 }} ~ {{ 2 < 1 }} ~ {{ 4 > 3 }}";
	writeln("result : ",Env.render(input, data));

	writeln("-------------Array value------------");
	input = "{{ addrs[0] }} or {{ users.name }}";
	writeln("result : ",Env.render(input, data));

	 writeln("-------------FUNC length------------");
	 input = "{{ length(name) }} or {{ length(users) }}";
	 writeln("result : ",Env.render(input, data));

	//Util.debug_ast(Env.parse(input).parsed_node);

	JSONValue d;
	d["appname"] = "Vitis";
	d["title"] = "this is test .";
	d["content"] = "Vitis is IM .";
	d["platform"] = "Android";
	d["pushscope"] = "IOS";
	d["type"] = "online";
	d["count"] = 100;
	d["time"] = "Fri Apr 13 17:36:13 CST 2018";
	d["savetotime"] = "Fri Apr 13 17:36:13 CST 2018";
	d["msgid"] = 1000;
	d["userinfo"] = userinfo;

	writeln("---------Render file  & save to file-----------");
	Env.write("detail.txt", d,"detail.html");

	writeln("------------------FUNCTION range-------------------------");
	input = "{% for id in range(4) %}{{id}} {% endfor %}";
	writeln("result : ",Env.render(input, data));

	writeln("------------------FUNCTION date-------------------------");
	input = "{{ date('Y-m-d H:i:s',time) }}";
	writeln("result : ",Env.render(input, data));

	writeln("------------------FUNCTION lang-------------------------");
	input = "{{ trans(\"message.hello-world\") }}";
	writeln("result : ",Env.render(input, data));

	writeln("------------------For array-------------------------");
	input = "{% for id in data %} {{ loop.index }} - {{id}} - {{ loop.index0 }}{% endfor %}";
	JSONValue test;
	JSONValue arr = ['a','b','c','d'];
	test["data"] =arr;
	writeln("result : ",Env.render(input, test));

	writeln("------------------IF defined/undefined/number/list/dict-------------------------");
	test["num"] = 12;
	input = "{% if data.defined %} defined {% else %} undefined {% endif %} \r\n
			{% if unknown.undefined %} undefined {% else %} defined {% endif %} \r\n
			{% if num.number %} is number {% else %} not is number {% endif %} \r\n
			{% if data.list %} is list {% else %} not is list {% endif %} \r\n";

	writeln("result : ",Env.render(input, test));

	writeln("------------------Int -------------------------");
	JSONValue testInt;
	testInt["num1"] = 12;
	testInt["num2"] = "12";
	testInt["num3"] = true;
	testInt["num4"] = false;

	input = "{{ int(num1) }} ~ {{ int(num2) }} ~ {{ int(num3) }} ~ {{ int(num4) }}";

	writeln("result : ",Env.render(input, testInt));

	writeln("------------------String -------------------------");
	JSONValue testString;
	testString["num1"] = 12;
	testString["num2"] = "12";
	testString["num3"] = true;
	testString["num4"] = false;

	input = "{{ string(num1) }} ~ {{ string(num2) }} ~ {{ string(num3) }} ~ {{ string(num4) }}";

	writeln("result : ",Env.render(input, testString));

}
