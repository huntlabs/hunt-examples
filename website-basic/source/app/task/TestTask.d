module app.task.TestTask;

import hunt.logging;
import hunt.util.worker;

import std.random;
import std.uuid;

import core.thread;



class TestTask : Task {

    private int _a;
	private int _b;

	this(int a, int b) {
		_a = a;
        _b = b;
        this.id = randomUUID().toHash();
	}


	override void doExecute() {
		infof("Task %d is running...", id);
		size_t times = 30;
		foreach(size_t index; 0..times) {
			tracef("Task %d is couting...", times-index);
			Thread.sleep(1.seconds);
		}
		infof("Task %d is done.", id);
	}
}