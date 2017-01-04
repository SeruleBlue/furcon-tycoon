package src.cobaltricindustries.fct.props.actor.logic {
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	/**
	 * Extended Idle logic for Furs that own at least 1 ConEvent.
	 * @author Serule Blue
	 */
	public class LogicSP_Owner extends ABST_Logic {
		
		/// How many minutes before an owned event starts to consider going to it.
		private const TIME_EARLY:int = 60;
		
		public function LogicSP_Owner(fur_:Fur) {
			super(fur_);
		}
		
		/**
		 * Returns true if the rest of the logic should be interrupted.
		 * @param	...args
		 * @return
		 */
		override public function runLogic(...args):* {
			// Check if there's an upcoming event that this Fur owns.
			if (fur.runningEvent == null && fur.schedule != null && System.rand(25)) {
				var upcomingEvents:Array = fur.schedule.getUpcomingEvents(TIME_EARLY);
				if (upcomingEvents.length == 0) {
					return false;
				}
				for each (var ce:ConEvent in upcomingEvents) {
					for each (var owned:ConEvent in fur.ownedEvents) {
						// There's an upcoming event this Fur owns; go to it
						if (owned == ce) {
							fur.eventOfInterest = owned;
							fur.runningEvent = owned;
							// Make your way to the event.
							fur.speed = ABST_Movable.NORMAL_SPEED
							fur.moveAndCallback(fur.eventOfInterest.room.getCoordinateLocation(), false, fur.brain["schedule"]);
							return true;
						}
					}
				}
			} else {
				return false;
			}
		}
	}
}