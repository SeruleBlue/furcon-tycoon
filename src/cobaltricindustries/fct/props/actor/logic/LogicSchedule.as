package src.cobaltricindustries.fct.props.actor.logic {
	import flash.geom.Point;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.SM;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	/**
	 * Determines if there's an event this Fur is interested in going to.
	 * @author Serule Blue
	 */
	public class LogicSchedule extends ABST_Logic {
		
		public function LogicSchedule(fur_:Fur) {
			super(fur_);
		}	
		
		/**
		 * If an eventOfInterest does not currently exist, attempt to pick a new one.
		 * @param	...args
		 */
		override public function runLogic(...args):void {
			// if arrival callback
			if (args[0] && args[0] == "arrive") {
				if (fur.eventOfInterest != null) {
					fur.state = SM.STATE_IN_EVENT;
					return;
				}
			}
			
			if (fur.eventOfInterest != null) {
				return;
			}
			
			// TODO improve event choosing logic
			// Pick a valid event.
			if (fur.schedule == null) {
				return;
			}
			var candidateEvents:Array = fur.schedule.getUpcomingEvents(45);
			if (candidateEvents.length == 0) {
				return;
			}
			fur.eventOfInterest = System.getRandFrom(candidateEvents);
			
			// Make your way to the event.
			fur.speed = ABST_Movable.NORMAL_SPEED
			fur.moveAndCallback(fur.eventOfInterest.room.getCoordinateLocation(), false, this);
		}
	}
}