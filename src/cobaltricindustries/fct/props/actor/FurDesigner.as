package src.cobaltricindustries.fct.props.actor {
	import src.cobaltricindustries.fct.System;
	/**
	 * Static class that helps create Fur personalities.
	 * @author Serule Blue
	 */
	public class FurDesigner {
		
		public static var furNum:int = 1;
		
		/// returns [0-1]; hits (0, 0), (.25, .4), (.5, .5), (.75, .6), (1, 1)
		public static const FN_CUBIC:Function = function(x:Number):Number {
			return 3 * Math.pow(x, 3) - 4.8 * Math.pow(x, 2) + 2.6 * x;
		}
		
		/// returns [0-1]; about 49% of values are from (.33, .88) to (.67, .88)
		public static const FN_PARABOLA:Function = function(x:Number):Number {
			return -4 * Math.pow(x - .5, 2) + 1;
		}
		
		/// returns [12-50]; roughly follows age distribution at http://vis.adjectivespecies.com/gender-age/
		public static const FN_AGE:Function = function(x:Number):int {
			// y = 95x^3 - 103x^2 + 44x + 13 from 0 to 1
			return int(95 * Math.pow(x, 3) - 103 * Math.pow(x, 2) + 44 * x + 13);
		}
		
		public function FurDesigner() {
			// Do not instiantiate.
		}
		
		/**
		 * Personalize the given Fur.
		 * @param	fur
		 */
		public static function designFur(fur:Fur):void {
			fur.handle = "Furry " + furNum++;			// TODO read from a list
			fur.age = FN_AGE(r());
			
			// Interest in any sort of art
			fur.traits["Art"] = FN_CUBIC(r());
		}
		
		/**
		 * Just a shorter function to return a random number from 0 to 1.
		 * @return
		 */
		private static function r():Number {
			return System.getRandNum(0, 1);
		}
		
		/**
		 * FN_AGE
			0 12
			.015 15
			.3 19
			.4 20
			.5 21
			.75 30
			.9 35
			1 50
		 * 
		 * 
		 * 
		 * 
		 */
	}
}