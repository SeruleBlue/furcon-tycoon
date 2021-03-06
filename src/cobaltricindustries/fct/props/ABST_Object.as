package src.cobaltricindustries.fct.props {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.actor.stats.Buff;
	import src.cobaltricindustries.fct.System;
	import flash.display.MovieClip;
	import flash.geom.Point;

	/**
	 * An abstract class containing functionality useful to all game objects.
	 * Should be managed by an ABST_Manager.
	 * @author Serule Blue
	 */
	public class ABST_Object {
		/// A reference to the active instance of ContainerGame
		public var cg:ContainerGame;
		
		/// The MovieClip associated with this object (The actual graphic on the stage)
		public var mc_object:MovieClip;
		
		/// Indicates if this object should be removed
		protected var completed:Boolean = false;
		
		/// Dictionary of numeric stats for this object. string -> [current, min, max, update_amount, update_counter, update_frequency]
		public var stats:Object = { };
		
		/// Dictionary of buff names to buffs for this object. Affects stats.
		public var buffs:Object = { };
		
		/// Helper for use in ABST_Manager.getNearby
		public var nearDistance:Number = 0;

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
		 * Get the current value of the given stat
		 * @param	key		stat
		 * @return
		 */
		public function getStat(key:String):Number {
			return stats[key][0];
		}
		
		/**
		 * Apply (add or renew) the given buff.
		 * @param	buff
		 */
		public function applyBuff(buff:Buff):void {
			if (buffs[buff.name] != null) {
				buffs[buff.name].reapply();
			} else {
				buffs[buff.name] = buff;
			}
		}
		
		/**
		 * Update all of this object's stats based on its buffs. Remove expired buffs.
		 */
		protected function updateStats():void {
			for (var key:String in buffs) {
				var buff:Buff = buffs[key];
				if (buff.step()) {
					buff.destroy();
					buff = null;
					buffs[key] = null;
					delete buffs[key];
				}
			}
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