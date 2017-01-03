package src.cobaltricindustries.fct.props.actor {
	import src.cobaltricindustries.fct.System;
	/**
	 * Static class that helps create Fur personalities.
	 * Attempts to emulate furry demographic data gathered from real-world surveys.
	 * @author Serule Blue
	 */
	public class FurDesigner {
		
		public static var furNum:int = 1;
		
		/// returns [0-1]; hits (0, 0), (.25, .4), (.5, .5), (.75, .6), (1, 1)
		public static const FN_CUBIC:Function = function(x:Number):Number {
			// y = 3.2x^3 - 4.8x^2 + 2.6x from 0 to 1
			return 3.2 * Math.pow(x, 3) - 4.8 * Math.pow(x, 2) + 2.6 * x;
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
		
		// favors con data over general fandom data
		// http://www.adjectivespecies.com/2014/06/12/furry-women-at-furry-conventions-some-more-data/
		/// returns "Male", "Female", or "Complicated"
		public static const FN_GENDER:Function = function():String {
			// con data
			return System.getRandomWeighted([["Male", 82], ["Female", 14], ["Complicated", 4]]);
			// general fandom data
			//return System.getRandomWeighted([["Male", 75.7], ["Female", 18.2], ["Complicated", 6.1]]);
		}
		
		// http://www.furcenter.org/pubs/SF_2008.pdf (pg 21)
		// returns interest in "Art"
		public static const FN_INT_ART:Function = function(x:Number):Number {
			// y = -1.065x^2 + 2.025x from 0 to 1
			return -1.065 * Math.pow(x, 2) + 2.025 * x;
		}
		
		// http://www.furcenter.org/pubs/SF_2008.pdf (pg 26)
		// returns interest in "Writing"
		public static const FN_INT_WRITING:Function = function(x:Number):Number {
			// y =  1.93x^3 -3.15x^2 + 2.2x from 0 to 1
			return 1.93 * Math.pow(x, 3) - 3.15 * Math.pow(x, 2) + 2.2 * x;
		}
		
		// http://www.furcenter.org/pubs/SF_2008.pdf (pg 25)
		// returns interest in "Fursuiting"
		public static const FN_INT_FURSUIT:Function = function(x:Number):Number {
			// y = 2.6x^3 -4.6x^2 + 3x from 0 to 1
			return 2.6 * Math.pow(x, 3) - 4.6 * Math.pow(x, 2) + 3 * x;
		}
		
		// http://www.furcenter.org/pubs/SF_2008.pdf (pg 25)
		// returns interest in "Music"
		public static const FN_INT_MUSIC:Function = function(x:Number):Number {
			// y =  1.45x^3 -1.94x^2 + 1.48x from 0 to 1
			return 1.45 * Math.pow(x, 3) - 1.94 * Math.pow(x, 2) + 1.48 * x;
		}

		// https://sites.google.com/site/anthropomorphicresearch/past-results/international-furry-survey-summer-2011
		// data is based off on how strongly one identifies as an artist
		/// returns how skilled an artist is
		public static const FN_SK_ART:Function = function(x:Number):Number {
			// y = 280x^3 - 400x^2 + 222x from 0 to 1
			return .01 * (280 * Math.pow(x, 3) - 400 * Math.pow(x, 2) + 222 * x);
		}
		
		/// returns money this fur has
		// https://sites.google.com/site/anthropomorphicresearch/past-results/anthrocon-2015
		public static const FN_MONEY:Function = function(x:Number):Number {
			// y = 1563x^4 - 2702x^3 + 1492x^2 - 224x + 10 from 0 to 1
			// returns from distribution of annual income (where raw is $raw,000/year)
			var raw:int = x < .1 ? 0 : int(1563 * Math.pow(x, 4) - 2702 * Math.pow(x, 3) + 1492 * Math.pow(x, 2) -244 * x + 10);
			// fix wonky negative numbers
			if (raw < 0) raw = 0;
			// randomly scale it
			raw = int(raw * System.getRandNum(0.6, 2));
			// return with random cents
			return raw + System.getRandInt(0, 99) * .01;
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
			fur.gender = FN_GENDER();
			fur.stats["money"][0] = FN_MONEY(r());
			
			// General interests - a Number from 0.00 (completely uninterested) to 1.00 (obsessed)
			fur.traits["Art"] = FN_INT_ART(r());
			fur.traits["Writing"] = FN_INT_WRITING(r());
			fur.traits["Fursuiting"] = FN_INT_FURSUIT(r());
			fur.traits["Music"] = FN_INT_MUSIC(r());
			
			// Skills - for a specific skill, either null or 0.00 (no skill) to 1.00 (prodigy)
			var skills:Object = { };
			skills["Art"] = FN_SK_ART(r());
			fur.traits["skills"] = skills;
		}
		
		/**
		 * Just a shorter function to return a random number from 0 to 1.
		 * @return
		 */
		private static function r():Number {
			return System.getRandNum(0, 1);
		}
		
		/**
		 * FN_CUBIC
			0, 0
			.25, .4
			.5, .5
			.75, .6
			.99, .99
			1, 1
		 * 
		 * 
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
		 * FN_SK_ART
			 0, 0
			.2, 25
			.3, 45
			.7, 50
			.9, 90
			1, 100
		 * 
		 * FN_INT_ART
			0, 0
			.006, .0
			.097, .33
			.431, .67
			1, 1
		 * 
		 * FN_MONEY
			.06 0
			.185 10
			.375 20
			.585 30
			.725 40
			.815 50
			.915 75
			.965 100
			1 150
		 */
	}
}