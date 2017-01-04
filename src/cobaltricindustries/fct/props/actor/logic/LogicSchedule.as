package src.cobaltricindustries.fct.props.actor.logic {
	import flash.geom.Point;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.SM;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	/**
	 * Determines if there's an event this Fur is interested in going to.
	 * @author Serule Blue
	 */
	public class LogicSchedule extends ABST_Logic {
		
		/// Maps previously-considered event names to % modifier of the next time the event is considered
		private var consideredEvents:Object = { };
		
		public function LogicSchedule(fur_:Fur) {
			super(fur_);
		}	
		
		/**
		 * If an eventOfInterest does not currently exist, attempt to pick a new one.
		 * @param	...args
		 */
		override public function runLogic(...args):* {
			// if arrival callback
			if (args[0] && args[0] == "arrive") {
				if (fur.eventOfInterest != null) {
					if (fur.runningEvent != null) {
						fur.state = SM.STATE_RUNNING_EVENT;
					} else {
						fur.state = SM.STATE_IN_EVENT;
					}
					return;
				}
			}
			
			if (fur.eventOfInterest != null) {
				return;
			}
			
			// Pick a valid event.
			if (fur.schedule == null) {
				return;
			}
			var candidateEvents:Array = fur.schedule.getUpcomingEvents(45);
			if (candidateEvents.length == 0) {
				return;
			}
			
			// from the choices, higher chance of picking more desirable events
			var choicesAndWeights:Array = [];
			var weights:Array = [];
			for each (var ce:ConEvent in candidateEvents) {
				var modifier:Number = consideredEvents[ce.name] != null ? consideredEvents[ce.name] : 1;
				var weight:Number = ce.getDesirability(fur.traits) * modifier;
				choicesAndWeights.push([ce, weight]);
				weights.push(weight);
			}
			// TODO reduce or increase % of previously-considered event?
			
			var chosenEvent:ConEvent = System.getRandomWeighted(choicesAndWeights);
			// slight chance of not attending even if desirability is 1.0
			if (weights[candidateEvents.indexOf(chosenEvent)] < System.getRandNum(0, 1.1)) {
				if (consideredEvents[ce.name] == null) {
					consideredEvents[ce.name] = 0.5;
				} else {
					consideredEvents[ce.name] *= 0.5;
				}
				return;
			}
			fur.eventOfInterest = chosenEvent;
			
			// Make your way to the event.
			fur.speed = ABST_Movable.NORMAL_SPEED
			fur.moveAndCallback(fur.eventOfInterest.room.getCoordinateLocation(), false, this);
		}
	}
}