package src.cobaltricindustries.fct.props.actor.logic {
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.SM;
	import src.cobaltricindustries.fct.System;
	/**
	 * Determine what to do while in an Event.
	 * @author Serule Blue
	 */
	public class LogicEvent extends ABST_Logic {
				
		public function LogicEvent(fur_:Fur) {
			super(fur_);
		}
		
		override public function runLogic(...args):void {
			if (fur.eventOfInterest == null) {
				return;
			}
			
			var currentTime:int = fur.cg.time.getCurrentTimestamp();
			// Check if the event has ended.
			if (currentTime > fur.eventOfInterest.getTimestamp(false)) {
				fur.resetAllInterests();
				fur.state = SM.STATE_IDLE;
				// TODO better way of reenabling drain
				fur.stats["happiness"][3] = -1;
				
				// TODO something better than this
				// See if there's something coming up on the schedule next, else 75% chance to move somewhere random.
				fur.brain["schedule"].runLogic();
				if (fur.eventOfInterest == null && System.rand(75)) {
					fur.brain["idle"].moveToRandomLocation();
				}
				
				return;
			}
			
			// TODO better stat management
			// Increase happiness as long as the event is going.
			if (currentTime >= fur.eventOfInterest.getTimestamp(true)) {
				// TODO better way of determining happiness change
				fur.stats["happiness"][3] = System.getRandInt(0, 9);
			}
		}
	}
}