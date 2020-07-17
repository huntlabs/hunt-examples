module app.model.Greeting;

import std.datetime;

class Greeting {
    string content;
    SysTime creationTime;
    long currentTime;

    override string toString() {
        return "content: " ~ content;
    }
}