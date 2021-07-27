module app.model.ValidForm;

import hunt.validation;
import hunt.framework.http.Form;
import hunt.serialization.JsonSerializer;

class User : Form
{
	mixin MakeForm;

	@Range(3,6)
	int age;

	@Length(4,1000)
	string name;

    @Email
	// @FormProperty("e-mail")
	@JsonProperty("e-mail")
    string email;

	string[] friends;

	this() {
		name = "test";
	}
}