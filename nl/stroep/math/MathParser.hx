package nl.stroep.math;

/**
 * Evaluates math expressions.
 *
 * Examples:
 * <code>
 * MathParser.parse("1+2-3/4*5"); // returns -0.75
 * MathParser.parse("1+2--3/4*5"); // returns 6.75
 * MathParser.parse("(1+2--3)/4*5"); // returns 7.5
 * MathParser.parse("(1+2- -3)/(4*.5)"); // returns 0.3
 * MathParser.parse("(.1+.2- -.3)/(.4*.5)"); // returns 3.0
 * MathParser.parse("0xff * 10"); // returns 2550.0
 * </code>
 *
 * @author Mark Knol [mediamonks]
 */
class MathParser {
	/**
	 * Evaluates math expressions. 
	 * Returns result as Float, Math.NEGATIVE_INFINITY when expression is invalid
	 */
	public static function parse(expr:String):Float {
		expr = expr.split(" ").join("").split("=").join("");

#if debug
		// validate parentheses by count
		if (expr.split(")").length != expr.split("(").length) {
			throw "Invalid parentheses in expression " + expr;
			return Math.NEGATIVE_INFINITY;
		}
#end

		var value = 0.0;
		var index = expr.indexOf(")");
		while (index != -1) {
			var rightIndex = expr.indexOf(")");
			var leftIndex = expr.substring(0, rightIndex).lastIndexOf("(");

			var group = expr.substring(leftIndex + 1, rightIndex);

			var newExpr = "";
			if (leftIndex != 0) {
				newExpr += expr.substring(0, leftIndex);
			}
			newExpr += validate(group);
			if (rightIndex != expr.length) {
				newExpr += expr.substring(rightIndex + 1, expr.length);
			}

			expr = newExpr;

			//trace("group: (" + group + ")=" + validate(group));

			index = expr.indexOf(")");
		}

		//trace("After validating groups: " + expr);

		return validate(expr);
	}

	static private function validate(expression:String) {
		var expressions:Array<String> = [""]; // Add empty
		var operators:Array<String> = [];
		var prevIndex:Int = 0;
		var isPrevOperator:Bool = true;

		for (expr in expression.split("")) {
			if (expr==("*") ||
				expr==("+") ||
				(expr==("-") && !isPrevOperator) ||
				expr==("(") ||
				expr==(")") ||
				expr==("/")) {
				// operators
				
				operators.push(expr);
				expressions.push("");
				prevIndex = expressions.length - 1;
				isPrevOperator = true;
			}
			else {
				// append [0-9.-] to value
				expressions[prevIndex] += expr;
				isPrevOperator = false;
			}
		}

		// parse values to floats
		var values = expressions.map(function(x) return x.indexOf (".")!=-1 ? Std.parseFloat(x) : cast Std.parseInt(x));

		// multiply and devide
		var multiplyIndex = operators.indexOf("*");
		var devideIndex = operators.indexOf("/");

		while (true) {
			if (multiplyIndex != -1 && (devideIndex == -1 || multiplyIndex < devideIndex)) {
				values[multiplyIndex] *= values[multiplyIndex + 1];

				values.splice(multiplyIndex + 1, 1);
				operators.splice(multiplyIndex, 1);
			}
			else if (devideIndex != -1 && (multiplyIndex == -1 || devideIndex < multiplyIndex)) {
				values[devideIndex] /= values[devideIndex + 1];

				values.splice(devideIndex + 1, 1);
				operators.splice(devideIndex, 1);
			}
			multiplyIndex = operators.indexOf("*");
			devideIndex = operators.indexOf("/");

			if (multiplyIndex == -1 && devideIndex == -1) break;
		}


		// add and remove
		var addIndex = operators.indexOf("+");
		var removeIndex = operators.indexOf("-");

		while (true) {
			if (addIndex != -1 && (removeIndex == -1 || addIndex < removeIndex)) {
				values[addIndex] += values[addIndex + 1];

				values.splice(addIndex + 1, 1);
				operators.splice(addIndex, 1);
			}
			else if (removeIndex != -1 && (addIndex == -1 || removeIndex < addIndex)) {
				values[removeIndex] -= values[removeIndex + 1];

				values.splice(removeIndex + 1, 1);
				operators.splice(removeIndex, 1);
			}
			addIndex = operators.indexOf("+");
			removeIndex = operators.indexOf("-");

			if (addIndex == -1 && removeIndex == -1) break;
		}

		return values[0];
	}
}
