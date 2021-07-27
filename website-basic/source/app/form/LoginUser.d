module app.form.LoginUser;

import hunt.framework.http.Form;
import hunt.validation;

import hunt.serialization.JsonSerializer;

class LoginUser : Form
{
	mixin MakeForm;

	@Length(4,12)
	string name;
    
	@Length(4,8)
    string password;

	@AliasField("e-mail")
    string email;

	bool rememeber = false;
}