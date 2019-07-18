module app.model.ValidForm;

import hunt.validation;
import hunt.framework.http.Form;

class User : Form
{
	mixin MakeForm;

	@Range(3,6)
	int age;

	@Length(4,1000)
	string name;

    @Email
    string email;

	string[] friends;
}