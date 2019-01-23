import std.stdio;
import std.traits;

import hunt.framework;
import hunt.logging;
import std.regex;


class User : Form
{

	mixin MakeForm;

	@Min(2)
	@Max(10)
	int id;

	@Pattern(`[\d+]$`)
	@Length(4,10)
	string name;

	@Email  
	string email;

	@NotEmpty
	string addr;

	@AssertTrue("must be male")
	bool male = true;

	@Range(18,30)
	int age;
}

void main()
{
	writeln("Edit source/app.d to start your project.");
	LogConf conf;
	logLoadConf(conf);

	auto user = new User();
	user.id = 10;
	user.name = "2123";
	user.email = "18601699402@163.com34";
	user.addr = "tianlin road";
	user.age = 18;
	auto context = user.valid();
	logDebug("Valid Context : ",context);
}

void test_validator(User user)
{
	// LengthValidator lenValidator = new LengthValidator();
	// lenValidator.initialize((getUDAs!(__traits(getMember, User ,"name"), Length)[0]));  
	// logDebug("LengthValidator : ",lenValidator.isValid(user.name,new DefaultConstraintValidatorContext()));

	// MinValidator minValidator = new MinValidator();
	// minValidator.initialize((getUDAs!(__traits(getMember, User ,"id"), Min)[0]));  
	// logDebug("MinValidator : ",minValidator.isValid(user.id,new DefaultConstraintValidatorContext()));

	// MaxValidator maxValidator = new MaxValidator();
	// maxValidator.initialize((getUDAs!(__traits(getMember, User ,"id"), Max)[0]));  
	// logDebug("MaxValidator : ",maxValidator.isValid(user.id,new DefaultConstraintValidatorContext()));

	// // EmailValidator emailValidator = new EmailValidator();
	// // emailValidator.initialize((getUDAs!(__traits(getMember, User ,"email"), Email)[0]));  
	// // logDebug("EmailValidator : ",emailValidator.isValid(user.email,new DefaultConstraintValidatorContext()));

	// NotEmptyValidator!string noteptValidator = new NotEmptyValidator!string();
	// noteptValidator.initialize((getUDAs!(__traits(getMember, User ,"addr"), NotEmpty)[0]));  
	// logDebug("NotEmptyValidator : ",noteptValidator.isValid(user.addr,new DefaultConstraintValidatorContext()));
}
