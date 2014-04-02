package nl.stroep.math;

/**
 * Evaluates math expressions.
 * 
 * Examples:
 * <code>
 * MathParser.parse("1+2-3/4*5"); // returns -0.75
 * MathParser.parse("1+2--3/4*5"); // returns 6.75
 * MathParser.parse("(1+2--3)/4*5"); // returns 7.5
 * MathParser.parse("(1+2- -3)/(((4*.5)))"); // returns 0.3
 * MathParser.parse("(.1+.2- -.3)/(.4*.5)"); // returns 3.0
 * </code>
 * 
 * @author Mark Knol [mediamonks]
 */
class MathParser
{
	/**
	 * Evaluates math expressions. 
	 * Returns result as Float, Math.NEGATIVE_INFINITY when expression is invalid
	 */
	public static function parse(expression:String):Float
	{
		//trace("Before validating groups: " + expr);
		var value = 0.0; 
		var index = expression.indexOf(")");
		while (index != -1)
		{
			var rightIndex = expression.indexOf(")");
			var leftIndex = expression.substring(0, rightIndex).lastIndexOf("(");
			
			var group = expression.substring(leftIndex + 1, rightIndex);
			
			var newExpr = "";
			if (leftIndex != 0) newExpr += expression.substring(0, leftIndex);
			newExpr += validate(group);
			if (rightIndex != expression.length) newExpr += expression.substring(rightIndex + 1, expression.length);
			
			expression = newExpr;
			
			//trace("group: (" + group + ")=" + validate(group));
			
			index = expression.indexOf(")");
		}
		
		//trace("After validating groups: " + expr);
		
		return validate(expression);
	}
	
	static private function validate(expression:String) 
	{
		var expressions:Array<String> = [""]; // Add empty
		var operators:Array<String> = [];
		var prevIndex:Int = 0;
		var isPrevOperator:Bool = true;

		for (expr in expression.split("")) 
		{
			if (Std.parseInt(expr) == null && expr != "." && !isPrevOperator)
			{
				// operator
				operators.push(expr);
				expressions.push("");
				prevIndex = expressions.length - 1;
				isPrevOperator = true;
			} 
			else 
			{
				// append [0-9.-] to value
				expressions[prevIndex] += expr;
				isPrevOperator = false;
			}
		}
		
		// multiply and devide
		var values = expressions.map(function(x) return Std.parseFloat(x));
		
		var multiplyIndex = operators.indexOf("*");
		var devideIndex = operators.indexOf("/");
		
		while (true)
		{
			if (multiplyIndex != -1 && (devideIndex == -1 || multiplyIndex < devideIndex))
			{
				values[multiplyIndex] *= values[multiplyIndex + 1];
				
				values.splice(multiplyIndex + 1, 1);
				operators.splice(multiplyIndex, 1);
			}
			else if (devideIndex != -1 && (multiplyIndex == -1 || devideIndex < multiplyIndex))
			{
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
		
		while (true)
		{
			if (addIndex != -1 && (removeIndex == -1 || addIndex < removeIndex))
			{
				values[addIndex] += values[addIndex + 1];
				
				values.splice(addIndex + 1, 1);
				operators.splice(addIndex, 1);
			}
			else if (removeIndex != -1 && (addIndex == -1 || removeIndex < addIndex))
			{
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
