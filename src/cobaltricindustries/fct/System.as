package src.cobaltricindustries.fct {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.MovieClip;
	import flash.display.NativeMenuItem;
	import flash.display.Stage;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	
	/**
	 * Helper functionality
	 * @author Serule Blue
	 */
	public class System {
		// global constants
		public static const GAME_WIDTH:int = 960;
		public static const GAME_HEIGHT:int = 600;
		public static const GAME_HALF_WIDTH:int = GAME_WIDTH / 2;
		public static const GAME_HALF_HEIGHT:int = GAME_HEIGHT / 2;
		
		// account for game's center registration point
		// NOTE: can be changed by Cam.as
		public static var GAME_OFFSX:int = GAME_HALF_WIDTH;
		public static var GAME_OFFSY:int = GAME_HALF_HEIGHT;
		
		// timing constants
		public static const SECOND:int = 30;
		public static const MINUTE:int = SECOND * 60;
		public static const FRAMES_IN_MINUTE:int = 15;		// number of frames to elapse in a game-minute
		public static const DAYS:Array = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
		
		// volume constants
		public static const VOL_BGM:Number = .4;
		
		/**
		 * Returns a random int between min and max
		 * @param	min		The lower bound
		 * @param	max		The upper bound
		 * @return			A random int between min and max
		 */
		public static function getRandInt(min:int, max:int):int {  
			return (int(Math.random() * (max - min + 1)) + min);
		}
		
		/**
		 * Returns a random Number between min and max
		 * @param	min		The lower bound
		 * @param	max		The upper bound
		 * @return			A random Number between min and max
		 */
		public static function getRandNum(min:Number, max:Number):Number {
			return Math.random() * (max - min) + min;
		}
		
		/**
		 * Given a probability chance, randomly return true or false.
		 * @param	chance	[0-100]
		 * @return
		 */
		public static function rand(chance:Number):Boolean {
			return getRandNum(0, 100) <= chance;
		}

		/**
		 * Get a random element from the given array
		 * @param	arr		The choices
		 * @return			A random element from arr
		 */
		public static function getRandFrom(arr:Array):* {
			return arr[getRandInt(0, arr.length - 1)];
		}
		
		/**
		 * Gets a random point in the hotel that isn't in the wall.
		 * @param	origin	ABST_Movable whose hitbox to use
		 * @return			A valid point
		 */
		public static function getRandomValidLocation(origin:ABST_Movable):Point {
			var tgt:Point;
			while (tgt == null || !origin.isPointValid(tgt)) {
				tgt = new Point(getRandInt( -GAME_HALF_WIDTH + 40, GAME_HALF_WIDTH - 40),
								getRandInt( -GAME_HALF_HEIGHT + 40, GAME_HALF_HEIGHT - 40));
			}
			return tgt;
		}
		
		/**
		 * Gets a random point in the room.
		 * @param	room
		 * @return
		 */
		public static function getRandomValidLocationInRoom(room:MovieClip):Point {
			return new Point(getRandNum(room.x - room.width * .5, room.x + room.width * .5),
							 getRandNum(room.y - room.height * .5, room.y + room.height * .5));
		}
		
		/**
		 * Gets a random item from the weighted list.
		 * @param	choicesAndWeights	Array of 2-element Arrays of [value, weight]
		 * @return
		 */
		public static function getRandomWeighted(choicesAndWeights:Array):* {
			var total:Number = 0;
			var i:int
			for (i = 0; i < choicesAndWeights.length; i++) {
				total += choicesAndWeights[i][1];
			}
			var r:Number = getRandNum(0, total);
			var c:Number = 0;
			for (i = 0; i < choicesAndWeights.length; i++) {
				c += choicesAndWeights[i][1];
				if (r <= c) {
					return choicesAndWeights[i][0];
				}
			}
			return choicesAndWeights[0][0];	// shouldn't happen
		}
		
		/**
		 * Returns a random color from the 4 main colors (RGYB)
		 * @param	excludes	An Array of colors to exclude, else null
		 * @return				A random color from the 4 main colors, excluding colors in excludes
		 */
		/*public static function getRandCol(excludes:Array = null):uint {
			var choices:Array = [COL_RED, COL_YELLOW, COL_GREEN, COL_BLUE];
			if (excludes != null)
				for each (var col:uint in excludes)
					choices.splice(choices.indexOf(col), 1);
			if (choices.length == 0)
				return System.COL_WHITE;
			return getRandFrom(choices);
		}*/
		
		/**
		 * Gets the sign of the given number
		 * @param	num			Number to get the sign of
		 * @return				1 if num is non-negative; -1 otherwise
		 */
		public static function getSign(num:Number):int {
			return num >= 0 ? 1 : -1;
		}

		/**
		 * Helper to set initial values from an attributes map
		 * @param	key			The key to use in attributes
		 * @param	attributes	A map of keys to values
		 * @param	fallback	Default to use if the attributes object doesn't contain a value for the key
		 * @return				The corresponding attribute from the map, or fallback if none exists
		 */
		public static function setAttribute(key:*, attributes:Object, fallback:* = null):* {
			return attributes[key] != null ? attributes[key] : fallback;
		}
		
		/**
		 * Converts degrees to radians
		 * @param	degrees		Value in degrees
		 * @return				Value in radians
		 */
		public static function degToRad(degrees:Number):Number {
			return degrees * .0175;
		}
		
		/**
		 * Converts radians to degrees
		 * @param	radians		Value in radians
		 * @return				Value in degrees
		 */
		public static function radToDeg(radians:Number):Number {
			return radians * 57.296;
		}

		/**
		 * Gets the distance in px between 2 points
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @return
		 */
		public static function getDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number {
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**
		 * Gets the distance in px between 2 MovieClips
		 * @param	from
		 * @param	to
		 * @return
		 */
		public static function getDistanceMc(from:MovieClip, to:MovieClip):Number {
			return getDistance(from.x, from.y, to.x, to.y);
		}
		
		/**
		 * Returns true if the two points are within range of each other
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @param	range
		 * @return
		 */
		public static function inRange(x1:Number, y1:Number, x2:Number, y2:Number, range:Number):Boolean {
			return getDistance(x1, y1, x2, y2) <= range;
		}
		
		/**
		 * Returns true if the two MovieClips are within range of each other
		 * @param	from
		 * @param	to
		 * @param	range
		 * @return
		 */
		public static function inRangeMc(from:MovieClip, to:MovieClip, range:Number):Boolean {
			return inRange(from.x, from.y, to.x, to.y, range);
		}

		/**
		 * Gets the angle between 2 points, returned in degrees
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @return	The angle between (x1, y1) and (x2, y2)
		 */ 
		public static function getAngle(x1:Number, y1:Number, x2:Number, y2:Number):Number {
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return radToDeg(Math.atan2(dy,dx));
		}
		
		/**
		 * Gets the angle between 2 MovieClips, returned in degrees
		 * @param	from
		 * @param	to
		 * @return
		 */
		public static function getAngleMc(from:MovieClip, to:MovieClip):Number {
			return getAngle(from.x, from.y, to.x, to.y);
		}

		/**
		 * Given a speed and facing, returns the change in x or change in y. Call twice to get both dX and dY.
		 * @param	spd				Pixels per frame the object is moving at
		 * @param	rot				Direction in degrees the object is facing
		 * @param	isX				If the method should return dX (true) or dY (false)
		 * @return					Change in x or y, depending on isX
		 */
		public static function forward(spd:Number, rot:Number, isX:Boolean):Number {
			return (isX ? Math.cos(degToRad(rot)) : Math.sin(degToRad(rot))) * spd;
		}
		
		/**
		 * Helper to change the value of a variable restricted within limits
		 * @param	original		The original value
		 * @param	change			The amount to change by
		 * @param	limLow			The minimum amount
		 * @param	limHigh			The maximum amount
		 * @return					The original plus change, with respect to limits
		 */
		public static function changeWithLimit(orig:Number, chng:Number,
										  	   limLow:Number = int.MIN_VALUE, limHigh:Number = int.MAX_VALUE):Number {
			orig += chng;
			orig = Math.max(orig, limLow);
			return Math.min(orig, limHigh);
		}

		/**
		 * Determines if val is not between the two limits, with an optional buffer
		 * @param	val				The original value
		 * @param	low				The lower limit
		 * @param	high			The upper limit
		 * @param	buffer			Buffer to subtract from low, add to high
		 * @return					val < low - buffer || val > high + buffer
		 */
		public static function outOfBounds(val:Number, low:Number, high:Number, buffer:Number = 0):Boolean {
			return (val < low - buffer || val > high + buffer);
		}
		
		/**
		 * Determines if val is not between the two limits, with an optional buffer; but only if val is approaching the limit
		 * @param	val				The original value
		 * @param	dVal			The change in the original value
		 * @param	low				The lower limit
		 * @param	high			The upper limit
		 * @param	buffer			Buffer to subtract from low, add to high
		 * @return					val < low - buffer || val > high + buffer
		 */
		public static function directionalOutOfBounds(val:Number, dVal:Number, low:Number, high:Number, buffer:Number = 0):Boolean {
			return outOfBounds(val, low, high, buffer) && ((val < low && dVal < 0) || (val > high && dVal > 0))
		}
		
		/**
		 * Place the given value inside the limits using wrapping
		 * @param	val		The value to wrap
		 * @param	limit	The max/min value
		 * @return			The wrapped value
		 */
		public static function wrap(val:Number, limit:Number):Number {
			if (val > limit)
				val -= limit * 2;
			else if (val < -limit)
				val += limit * 2;
			return val;
		}
		
		public static function setWithinLimits(newValue:Number, limLow:Number = int.MIN_VALUE, limHigh:Number = int.MAX_VALUE):Number {
			return Math.max(Math.min(newValue, limHigh), limLow);
		}
		
		/**
		 * Pads a number with leading 0's as needed.
		 * @param	num		the number to pad [0-99]
		 * @return
		 */
		public static function pad(num:int):String {
			// TODO pad for arbitary number of 0's, if needed
			var numString:String = "";
			if (num < 10) {
				numString = "0";
			}
			return numString + num.toString();
		}
		
		/**
		 * Convert the name of a color to the corresponding uint code
		 * @param	colStr		color name, such as "red"
		 * @return				corespoinding uint (white if not found)
		 */
		/*public static function stringToCol(colStr:String):uint {
			switch (colStr)
			{
				case "red":		return COL_RED;
				case "green":	return COL_GREEN;
				case "blue":	return COL_BLUE;
				case "yellow":	return COL_YELLOW;
				default:		return COL_WHITE;
			}
		}*/
		
		/**
		 * Tint the given MovieClip
		 * @param	mc		The MovieClip to tint
		 * @param	col		The color to tint the MovieClip
		 * @param	mult	Option to reduce the tint
		 */
		/*public static function tintObject(mc:MovieClip, col:uint, mult:Number = 1):void {
			var ct:ColorTransform = new ColorTransform();
			if (col != COL_WHITE)
			{
				ct.redMultiplier = (col >> 16 & 0x0000FF / 255) * mult;
				ct.greenMultiplier = (col >> 8 & 0x0000FF / 255) * mult;
				ct.blueMultiplier = (col & 0x0000FF / 255) * mult;
			}
			mc.transform.colorTransform = ct;
		}*/

		/**
		 * Determine if a line can be drawn between origin and target without colliding with the hitbox
		 * @param	anchor		Any instance of an ABST_Movable; helps with collision detection
		 * @param	origin		Origin of LOS check
		 * @param	target		Target that origin is looking at
		 * @param	offset		Amount to adjust origin
		 * @return				true if origin has LOS on target
		 */
		public static function hasLineOfSight(origin:ABST_Movable, target:Point, offset:Point = null ):Boolean {
			if (offset == null) offset = new Point();
			var angle:Number = getAngle(origin.mc_object.x, origin.mc_object.y, target.x, target.y);
			var distMax:int = int(getDistance(origin.mc_object.x, origin.mc_object.y, target.x, target.y));
			var dist:int = 1;
			const DIST_STEP:int = 2;
			while (dist < distMax) {
				var ptL:Point = MovieClip(origin.mc_object.parent).localToGlobal(new Point(origin.mc_object.x + offset.x + forward(dist, angle, true), origin.mc_object.y + offset.y + forward(dist, angle, false)));
				if (origin.hitMask.hitTestPoint(ptL.x, ptL.y, true)) {
					return false;
				}
				dist += DIST_STEP;
			}
			return true;
		}
		
		/**
		 * Check LOS normally and from 4 different points around the origin
		 * @param	tgt		Target of LOS check
		 * @return			true if buffered LOS between origin and tgt
		 */
		public static function extendedLOScheck(origin:ABST_Movable, tgt:Point, buffer:int = 2):Boolean {
			return System.hasLineOfSight(origin, tgt) &&
				   System.hasLineOfSight(origin, tgt, new Point(-buffer, 0)) && System.hasLineOfSight(origin, tgt, new Point(buffer, 0)) &&
				   System.hasLineOfSight(origin, tgt, new Point(0, -buffer)) && System.hasLineOfSight(origin, tgt, new Point(0, buffer));
		}
		
		/**
		 * Returns the MC in the list that is closest to the mouse.
		 * @param	cg		Instance of ContainerGame
		 * @param	mcArr	Array of MovieClips whose distances to check
		 * @return			Nearest MC to the mouse
		 */
		public static function getNearestToMouse(cg:ContainerGame, mcArr:Array):MovieClip {
			var nearestMC:MovieClip;
			var nearestDist:Number = 99999;
			for each (var mc:MovieClip in mcArr) {
				var loc:Point = mc.parent.localToGlobal(new Point(mc.x, mc.y));
				var dist:Number = getDistance(cg.mouseX, cg.mouseY, loc.x, loc.y);
				if (dist < nearestDist) {
					nearestDist = dist;
					nearestMC = mc;
				}
			}
			return mc;
		}
		
		public static function calculateAverage(values:Array):Number {
			if (!values || values.length == 0)
				return 0;
			var total:Number = 0;
			for each (var n:Number in values)
				total += n;
			return total / values.length;
		}
		
		public static function toTimestamp(hours:int, minutes:int):int {
			return hours * 60 + minutes;
		}
		
		/**
		 * Converts a timestamp to [hours, minutes]
		 * @param	timestamp
		 * @return
		 */
		public static function fromTimestamp(timestamp:int):Array {
			return [timestamp / 60, timestamp % 60];
		}
	}
}