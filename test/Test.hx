import nl.stroep.math.MathParser.parse;
import Assert.assert;

class Test {
	static function main() {
		assert(parse("1+2-3/4*5") == -0.75);
		assert(parse("1+2--3/4*5") == 6.75);
		assert(parse("(1+2--3)/4*5") == 7.5);
		assert(parse("(1+2- -3)/(((4*.5)))") == 3);
		assert(parse("0xFF * 10") == 2550);
	}
}