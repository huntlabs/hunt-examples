/*
 * Copyright 2002-2016 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module test.messaging.MessageHeadersTests;

import hunt.framework.messaging.MessageHeaders;

import hunt.container;
import hunt.lang.Integer;
import hunt.lang.Nullable;
import hunt.logging;
import hunt.string;
import hunt.util.UnitTest;
import hunt.util.Assert;

import core.thread;
import core.time;
import std.uuid;

alias assertTrue = Assert.assertTrue;
alias assertFalse = Assert.assertFalse;
alias assertThat = Assert.assertThat;
alias assertEquals = Assert.assertEquals;
alias assertNull = Assert.assertNull;
alias assertNotNull = Assert.assertNotNull;
alias assertNotSame = Assert.assertNotSame;

/**
 * Test fixture for {@link MessageHeaders}.
 *
 * @author Rossen Stoyanchev
 * @author Gary Russell
 * @author Juergen Hoeller
 */
class MessageHeadersTests {

	@Test
	void testTimestamp() {
		MessageHeaders headers = new MessageHeaders(null);
		assertNotNull(headers.getTimestamp());
	}

	@Test
	void testTimestampOverwritten() {
		MessageHeaders headers1 = new MessageHeaders(null);
		Thread.sleep(50.msecs);
		MessageHeaders headers2 = new MessageHeaders(headers1);
		assertNotSame(headers1.getTimestamp(), headers2.getTimestamp());
	}

	@Test
	void testTimestampProvided() {
		MessageHeaders headers = new MessageHeaders(null, null, 10L);
		assertEquals(10L, cast(long)cast(Nullable!long) headers.getTimestamp());
	}

	// @Test
	// void testTimestampProvidedNullValue() {
	// 	Map!(string, Object) input = Collections.singletonMap!(string, Object)(MessageHeaders.TIMESTAMP, 1L);
	// 	MessageHeaders headers = new MessageHeaders(input, null, null);
	// 	assertNotNull(headers.getTimestamp());
	// }

	@Test
	void testTimestampNone() {
		MessageHeaders headers = new MessageHeaders(null, null, -1L);
		assertNull(headers.getTimestamp());
	}

	@Test
	void testIdOverwritten() {
		MessageHeaders headers1 = new MessageHeaders(null);
		MessageHeaders headers2 = new MessageHeaders(headers1);
		assertNotSame(headers1.getId(), headers2.getId());
	}

	@Test
	void testId() {
		MessageHeaders headers = new MessageHeaders(null);
		assert(headers.getId() != UUID.init);
		// assertNotNull(headers.getId());
	}

	@Test
	void testIdProvided() {
		UUID id = randomUUID();
		MessageHeaders headers = new MessageHeaders(null, &id, null);
		assertEquals(id, headers.getId());
	}

	// @Test
	// void testIdProvidedNullValue() {
	// 	Map!(string, Object) input = Collections.singletonMap!(string, Object)(MessageHeaders.ID, randomUUID());
	// 	MessageHeaders headers = new MessageHeaders(input, null, null);
	// 	assertNotNull(headers.getId());
	// }

	@Test
	void testIdNone() {
		MessageHeaders headers = new MessageHeaders(null, &MessageHeaders.ID_VALUE_NONE, null);
		assertNull(headers.getId());
	}

	@Test
	void testNonTypedAccessOfHeaderValue() {
		Integer value = new Integer(123);
		Map!(string, Object) map = new HashMap!(string, Object)();
		map.put("test", value);
		MessageHeaders headers = new MessageHeaders(map);
		assertEquals(value, headers.get("test"));
	}

	@Test
	void testTypedAccessOfHeaderValue() {
		Integer value = new Integer(123);
		Map!(string, Object) map = new HashMap!(string, Object)();
		map.put("test", value);
		MessageHeaders headers = new MessageHeaders(map);
		assertEquals(value, cast(Integer)headers.get("test"));
	}

	@Test
	void testHeaderValueAccessWithIncorrectType() {
		Integer value = new Integer(123);
		Map!(string, Object) map = new HashMap!(string, Object)();
		map.put("test", value);
		MessageHeaders headers = new MessageHeaders(map);
		assertEquals(value, cast(Integer)headers.get("test"));
	}

	@Test
	void testNullHeaderValue() {
		Map!(string, Object) map = new HashMap!(string, Object)();
		MessageHeaders headers = new MessageHeaders(map);
		assertNull(headers.get("nosuchattribute"));
	}

	@Test
	void testNullHeaderValueWithTypedAccess() {
		Map!(string, Object) map = new HashMap!(string, Object)();
		MessageHeaders headers = new MessageHeaders(map);
		assertNull(headers.getAs!(string)("nosuchattribute"));
	}

	@Test
	void testHeaderKeys() {
		Map!(string, Object) map = new HashMap!(string, Object)();
		map.put("key1", new String("val1"));
		map.put("key2", new Integer(123));
		MessageHeaders headers = new MessageHeaders(map);
		string[] keys = headers.keySet();
		assertTrue(keys.contains("key1"));
		assertTrue(keys.contains("key2"));
	}

	// @Test
	// void serializeWithAllSerializableHeaders() {
	// 	Map!(string, Object) map = new HashMap!(string, Object)();
	// 	map.put("name", "joe");
	// 	map.put("age", 42);
	// 	MessageHeaders input = new MessageHeaders(map);
	// 	MessageHeaders output = (MessageHeaders) SerializationTestUtils.serializeAndDeserialize(input);
	// 	assertEquals("joe", output.get("name"));
	// 	assertEquals(42, output.get("age"));
	// 	assertEquals("joe", input.get("name"));
	// 	assertEquals(42, input.get("age"));
	// }

	// @Test
	// void serializeWithNonSerializableHeader() {
	// 	Object address = new Object();
	// 	Map!(string, Object) map = new HashMap!(string, Object)();
	// 	map.put("name", "joe");
	// 	map.put("address", address);
	// 	MessageHeaders input = new MessageHeaders(map);
	// 	MessageHeaders output = (MessageHeaders) SerializationTestUtils.serializeAndDeserialize(input);
	// 	assertEquals("joe", output.get("name"));
	// 	assertNull(output.get("address"));
	// 	assertEquals("joe", input.get("name"));
	// 	assertSame(address, input.get("address"));
	// }

	@Test
	void testSubclassWithCustomIdAndNoTimestamp() {

		UUID id = UUID("00000000-0000-0000-0000-000000000001");
		class MyMH : MessageHeaders {
			this() {
				super(null, &id, -1L);
			}
		}

		MessageHeaders headers = new MyMH();
		assertEquals("00000000-0000-0000-0000-000000000001", headers.getId().toString());
		assertEquals(1, headers.size());
	}

}
