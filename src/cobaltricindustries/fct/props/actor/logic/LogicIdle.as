package src.cobaltricindustries.fct.props.actor.logic {
	import flash.geom.Point;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	/**
	 * Determine what to do when idle.
	 * @author Serule Blue
	 */
	public class LogicIdle extends ABST_Logic {
		
		public function LogicIdle(fur_:Fur) {
			super(fur_);
		}
		
		override public function runLogic(...args):void {
			// Do absolutely nothing.
			if (System.rand(99)) {
				return;
			}
			
			// Attempt to schedule and attend an event.
			else if (fur.eventOfInterest == null && System.rand(50)) {
				fur.brain["schedule"].runLogic();
				return;
			}
			
			// Randomly move nearby.
			else if (System.rand(75)) {
				var angle:Number = System.getRandNum(0, 360);
				var dist:Number = System.getRandNum(2, 25);
				var tgt:Point = new Point(System.forward(dist, angle, true), System.forward(dist, angle, false));
				tgt = tgt.add(new Point(fur.mc_object.x, fur.mc_object.y));
				if (System.hasLineOfSight(fur, tgt)) {
					fur.brain["move"].beelineCounter = 0;
					fur.speed = ABST_Movable.NORMAL_SPEED * .2;
					fur.setPOI(tgt, true);
				}
				return;
			}
			
			else {
				moveToRandomLocation();
			}
		}
		
		public function moveToRandomLocation():void {
			fur.speed = ABST_Movable.NORMAL_SPEED;
			fur.setPOI(System.getRandomValidLocation(fur));
		}
	}
}