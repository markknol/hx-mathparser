import haxe.macro.Expr;
using haxe.macro.Tools;

/** Source: <https://code.haxe.org/category/macros/assert-with-values.html> (modified) **/
class Assert {
  static public macro function assert(e:Expr) {
    var s = e.toString();
    var p = e.pos;
    var el = [];
    var descs = [];
    function add(e:Expr, s:String) {
      var v = "_tmp" + el.length;
      el.push(macro var $v = $e);
      descs.push(s);
      return v;
    }
    function map(e:Expr) {
      return switch (e.expr) {
        case EConst((CInt(_) | CFloat(_) | CString(_) | CRegexp(_) | CIdent("true" | "false" | "null"))):
          e;
        case _:
          var s = e.toString();
          e = e.map(map);
          macro $i{add(e, s)};
        }
    }
    var e = map(e);
    var a = [for (i in 0...el.length) macro { expr: $v{descs[i]}, value: $i{"_tmp" + i} }];
    el.push(macro if (!$e) @:pos(p) throw new Assert.Message(false, $v{s}, $a{a}).toString() else trace(new Assert.Message(true, $v{s}, $a{a}).toString()));
    return macro $b{el};
  }
}

private typedef AssertionPart = {
  expr: String,
  value: Any,
}

class Message {
  public var message(default, null):String;
  public var success(default, null):Bool;
  public var parts(default, null):Array<AssertionPart>;
  
  public inline function new(success:Bool, message:String, parts:Array<AssertionPart>) {
    this.success = success;
	this.message = message;
    this.parts = parts;
  }

  public inline function toString() {
    var buf = new StringBuf();
	
    if (success) buf.add("Assertion success: " + message);
	else buf.add("Assertion failure: " + message);
	
    for (part in parts) {
        buf.add("\n\t" + part.expr + ": " + part.value);
    }
    return buf.toString();
  }
}