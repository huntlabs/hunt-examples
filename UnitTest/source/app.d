import hunt.lang.exception;
import hunt.util.UnitTest;
import hunt.logging;

import test.messaging.MessageHeadersTests;
import test.messaging.simp.stomp.StompDecoderTests;

void main()
{
	// testUnits!(MessageHeadersTests);
	testUnits!(StompDecoderTests);
}
