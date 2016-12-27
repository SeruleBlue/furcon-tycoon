package cobaltricindustries.fct.props {
	import cobaltricindustries.fct.ContainerGame;
	import cobaltricindustries.fct.System;
	import flash.display.MovieClip;
	import flash.geom.Point;

	/**
	 * An abstract class containing functionality useful to all game objects
	 * @author Serule Blue
	 */
	public class ABST_Object {
		/// A reference to the active instance of ContainerGame
		protected var cg:ContainerGame;
		
		/// The MovieClip associated with this object (The actual graphic on the stage)
		public var mc_object:MovieClip;
		
		/// Indicates if this object should be removed
		protected var completed:Boolean = false;
		
		/// Dictionary of numeric stats for this object. string -> [current, min, max]
		protected var stats:Object = {};

		/**
		 * Should only be called through super(), never instantiated
		 * @param	_cg		The active instance of ContainerGame
		 */
		public function ABST_Object(_cg:ContainerGame, _mc_object:MovieClip = null) {
			cg = _cg;
			mc_object = _mc_object;
		}
		
		/**
		 * Update this object
		 * @return			true if the object is done and should be cleaned up
		 */
		public function step():Boolean {
			return completed;
		}
		
		/**
		 * Returns if this object is not slated for deletion
		 * @return			true if this object should still be in the game doing things
		 */
		public function isActive():Boolean {
			return !completed && mc_object != null;
		}

		/**
		 * Scale this object in both X and Y
		 * @param	scale	the amount to scale by (1.0 is original scale)
		 */
		public function setScale(scale:Number):void {
			mc_object.scaleX = mc_object.scaleY = scale;
		}
		
		/**
		 * Update this object's position
		 * @param	dx		the amount to change in the horizontal direction
		 * @param	dy		the amount to change in the vertical direction
		 */
		protected function updatePosition(dx:Number, dy:Number):void {
			if (mc_object != null) {
				mc_object.x += dx;
				mc_object.y += dy;
			}
		}
		
		/**
		 * Update this object's rotation
		 * @param	dr		the amount to change in the clockwise direction, in degrees
		 */
		protected function updateRotation(dr:Number):void {
			if (mc_object != null) {
				mc_object.rotation = (mc_object.rotation + dr) % 360;
			}
		}
		
		/**
		 * Change one of this object's stats.
		 * @param	key		string corresponding to the stat's key
		 * @param	amt		A Number to change the stat by; can be positive or negative
		 * @return			the new value of the stat
		 */
		public function changeStat(key:String, amt:Number):Number {
			if (!stats[key]) {
				trace('[' + this + '] Key does not exist! ' + key);
				return 0;
			}
			stats[key][0] = System.changeWithLimit(stats[key][0], amt, stats[key][1], stats[key][2]);
			return stats[key][0];
		}
		
		/**
		 * Helper to get the distance from this object to another
		 * @param	other		the other ABST_Obect
		 * @return				the distance in pixels
		 */
		public function getDistance(other:ABST_Object):Number {
			return System.getDistance(mc_object.x, mc_object.y, other.mc_object.x, other.mc_object.y);
		}
		
		/**
		 * Allows for extra actions to be performed when object spawns
		 */
		public function spawnActions():void {
			// -- override this function
		}
		
		/**
		 * Clean-up function, but without any extra effects
		 */
		public function destroySilently():void {
			// -- override this function
			destroy();
		}
		
		/**
		 * Clean-up function
		 */
		public function destroy():void {
			if (mc_object && MovieClip(mc_object.parent).contains(mc_object)) {
				MovieClip(mc_object.parent).removeChild(mc_object);
			}
			mc_object = null;
			cg = null;
			completed = true;
		}
	}
}