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

module test.messaging.simp.stomp.StompDecoderTests;

import hunt.framework.messaging.exception;
import hunt.framework.messaging.Message;
import hunt.framework.messaging.simp.SimpMessageType;
import hunt.framework.messaging.simp.stomp.StompCommand;
import hunt.framework.messaging.simp.stomp.StompDecoder;
import hunt.framework.messaging.simp.stomp.StompHeaderAccessor;

import hunt.container;
import hunt.lang.exception;
import hunt.lang.Integer;
import hunt.lang.Nullable;
import hunt.logging;
import hunt.string;
import hunt.util.UnitTest;
import hunt.util.Assert;

import core.thread;
import core.time;
import std.conv;
import std.exception;
import std.uuid;

alias assertTrue = Assert.assertTrue;
alias assertFalse = Assert.assertFalse;
alias assertThat = Assert.assertThat;
alias assertEquals = Assert.assertEquals;
alias assertNull = Assert.assertNull;
alias assertNotNull = Assert.assertNotNull;
alias assertNotSame = Assert.assertNotSame;

/**
 * Test fixture for {@link StompDecoder}.
 *
 * @author Andy Wilkinson
 * @author Stephane Maldini
 */
class StompDecoderTests {

	private StompDecoder decoder;


	this() {
		decoder = new StompDecoder();
	}

	@Test
	void decodeFrameWithCrLfEols() {
		Message!(byte[]) frame = decode("DISCONNECT\r\n\r\n\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.DISCONNECT, headers.getCommand());
		assertEquals(0, headers.toNativeHeaderMap().size());
		assertEquals(0, frame.getPayload().length);
	}

	@Test
	void decodeFrameWithNoHeadersAndNoBody() {
		Message!(byte[]) frame = decode("DISCONNECT\n\n\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.DISCONNECT, headers.getCommand());
		assertEquals(0, headers.toNativeHeaderMap().size());
		assertEquals(0, frame.getPayload().length);
	}

	@Test
	void decodeFrameWithNoBody() {
		string accept = "accept-version:1.1\n";
		string host = "host:github.org\n";

		Message!(byte[]) frame = decode("CONNECT\n" ~ accept ~ host ~ "\n\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.CONNECT, headers.getCommand());

		assertEquals(2, headers.toNativeHeaderMap().size());
		assertEquals("1.1", headers.getFirstNativeHeader("accept-version"));
		assertEquals("github.org", headers.getHost());

		assertEquals(0, frame.getPayload().length);
	}

	@Test
	void decodeFrame() {
		Message!(byte[]) frame = decode("SEND\ndestination:test\n\nThe body of the message\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.SEND, headers.getCommand());

		assertEquals(headers.toNativeHeaderMap().toString(), 1, headers.toNativeHeaderMap().size());
		assertEquals("test", headers.getDestination());

		string bodyText = cast(string) (frame.getPayload());
		assertEquals("The body of the message", bodyText);
	}

	@Test
	void decodeFrameWithContentLength() {
		Message!(byte[]) message = decode("SEND\ncontent-length:23\n\nThe body of the message\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(message);

		assertEquals(StompCommand.SEND, headers.getCommand());

		assertEquals(1, headers.toNativeHeaderMap().size());
		assertEquals(Integer.valueOf(23), headers.getContentLength());

		string bodyText = cast(string) (message.getPayload());
		assertEquals("The body of the message", bodyText);
	}

	// SPR-11528

	@Test
	void decodeFrameWithInvalidContentLength() {
		Message!(byte[]) message = decode("SEND\ncontent-length:-1\n\nThe body of the message\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(message);

		assertEquals(StompCommand.SEND, headers.getCommand());

		assertEquals(1, headers.toNativeHeaderMap().size());
		assertEquals(Integer.valueOf(-1), headers.getContentLength());

		string bodyText = cast(string) (message.getPayload());
		assertEquals("The body of the message", bodyText);
	}

	@Test
	void decodeFrameWithContentLengthZero() {
		Message!(byte[]) frame = decode("SEND\ncontent-length:0\n\n\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.SEND, headers.getCommand());

		assertEquals(1, headers.toNativeHeaderMap().size());
		assertEquals(Integer.valueOf(0), headers.getContentLength());

		string bodyText = cast(string) (frame.getPayload());
		assertEquals("", bodyText);
	}

	@Test
	void decodeFrameWithNullOctectsInTheBody() {
		Message!(byte[]) frame = decode("SEND\ncontent-length:23\n\nThe b\0dy \0f the message\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.SEND, headers.getCommand());

		assertEquals(1, headers.toNativeHeaderMap().size());
		assertEquals(Integer.valueOf(23), headers.getContentLength());

		string bodyText = cast(string) (frame.getPayload());
		assertEquals("The b\0dy \0f the message", bodyText);
	}

	@Test
	void decodeFrameWithEscapedHeaders() {
		Message!(byte[]) frame = decode("DISCONNECT\na\\c\\r\\n\\\\b:alpha\\cbravo\\r\\n\\\\\n\n\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.DISCONNECT, headers.getCommand());

		assertEquals(1, headers.toNativeHeaderMap().size());
		assertEquals("alpha:bravo\r\n\\", headers.getFirstNativeHeader("a:\r\n\\b"));
	}

	@Test
	void decodeFrameBodyNotAllowed() {
		assertThrown!(StompConversionException)(
			decode("CONNECT\naccept-version:1.2\n\nThe body of the message\0")
		);
	}

	@Test
	void decodeMultipleFramesFromSameBuffer() {
		string frame1 = "SEND\ndestination:test\n\nThe body of the message\0";
		string frame2 = "DISCONNECT\n\n\0";
		ByteBuffer buffer = ByteBuffer.wrap(cast(byte[])(frame1 ~ frame2));

		List!(Message!(byte[])) messages = decoder.decode(buffer);

		assertEquals(2, messages.size());
		assertEquals(StompCommand.SEND, StompHeaderAccessor.wrap(messages.get(0)).getCommand());
		assertEquals(StompCommand.DISCONNECT, StompHeaderAccessor.wrap(messages.get(1)).getCommand());
	}

	// SPR-13111

	@Test
	void decodeFrameWithHeaderWithEmptyValue() {
		string accept = "accept-version:1.1\n";
		string valuelessKey = "key:\n";

		Message!(byte[]) frame = decode("CONNECT\n" ~ accept ~ valuelessKey ~ "\n\0");
		StompHeaderAccessor headers = StompHeaderAccessor.wrap(frame);

		assertEquals(StompCommand.CONNECT, headers.getCommand());

		assertEquals(2, headers.toNativeHeaderMap().size());
		assertEquals("1.1", headers.getFirstNativeHeader("accept-version"));
		assertEquals("", headers.getFirstNativeHeader("key"));

		assertEquals(0, frame.getPayload().length);
	}

	@Test
	void decodeFrameWithIncompleteCommand() {
		assertIncompleteDecode("MESSAG");
	}

	@Test
	void decodeFrameWithIncompleteHeader() {
		assertIncompleteDecode("SEND\ndestination");
		assertIncompleteDecode("SEND\ndestination:");
		assertIncompleteDecode("SEND\ndestination:test");
	}

	@Test
	void decodeFrameWithoutNullOctetTerminator() {
		assertIncompleteDecode("SEND\ndestination:test\n");
		assertIncompleteDecode("SEND\ndestination:test\n\n");
		assertIncompleteDecode("SEND\ndestination:test\n\nThe body");
	}

	@Test
	void decodeFrameWithInsufficientContent() {
		assertIncompleteDecode("SEND\ncontent-length:23\n\nThe body of the mess");
	}

	@Test
	void decodeFrameWithIncompleteContentType() {
		assertIncompleteDecode("SEND\ncontent-type:text/plain;charset=U");
	}

// TODO: Tasks pending completion -@zxp at 11/7/2018, 3:54:04 PM
// 
	// @Test
	// void decodeFrameWithInvalidContentType() {
	// 	assertIncompleteDecode("SEND\ncontent-type:text/plain;charset=U\n\nThe body\0");
	// }

	@Test
	void decodeFrameWithIncorrectTerminator() {
		assertThrown!(StompConversionException)(
			decode("SEND\ncontent-length:23\n\nThe body of the message*")
		);
	}

	@Test
	void decodeHeartbeat() {
		string frame = "\n";

		ByteBuffer buffer = ByteBuffer.wrap(cast(byte[])frame);

		List!(Message!(byte[])) messages = decoder.decode(buffer);

		assertEquals(1, messages.size());
		assertEquals(SimpMessageType.HEARTBEAT, StompHeaderAccessor.wrap(messages.get(0)).getMessageType());
	}

	private void assertIncompleteDecode(string partialFrame) {
		ByteBuffer buffer = ByteBuffer.wrap(cast(byte[])partialFrame);
		assertNull(decode(buffer));
		assertEquals(0, buffer.position());
	}

	private Message!(byte[]) decode(string stompFrame) {
		ByteBuffer buffer = ByteBuffer.wrap(cast(byte[])stompFrame);
		return decode(buffer);
	}

	private Message!(byte[]) decode(ByteBuffer buffer) {
		List!(Message!(byte[])) messages = this.decoder.decode(buffer);
		if (messages.isEmpty()) {
			return null;
		}
		else {
			return messages.get(0);
		}
	}

}
