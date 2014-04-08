MathParser
==========

Evaluates math expressions. Uses Haxe.

### Examples

```haxe
MathParser.parse("1+2-3/4*5"); 
// returns -0.75

MathParser.parse("1+2--3/4*5"); 
// returns 6.75

MathParser.parse("(1+2--3)/4*5"); 
// returns 7.5

MathParser.parse("(1+2- -3)/(((4*.5)))"); 
// returns 0.3

MathParser.parse("(.1+.2- -.3)/(.4*.5)"); 
// returns 3.0000000000000004
```
_The parser assumes that the given expression is valid_
