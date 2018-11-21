module app.model.ValidForm;

import hunt.validation;
import hunt.framework.http.Form;

class User : Form
{
	mixin MakeForm;

	@Range(3,6)
	int age;

	@Length(4,10)
	string name;

    @Email
    string email;
}