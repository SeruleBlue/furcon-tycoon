package src.cobaltricindustries.fct.support.conevent {
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.props.actor.logic.LogicSP_Owner;
	import src.cobaltricindustries.fct.System;
	/**
	 * A single event in the con.
	 * @author Serule Blue
	 */
	public class ConEvent {
		public var name:String;
		/// Length of the event in minutes, [start, end)
		public var duration:int;
		
		// logistics details
		public var room:ConRoom;
		public var day:String;
		public var startHour:int = -1;
		public var startMinute:int = -1;
		public var endHour:int = -1;
		public var endMinute:int = -1;
		public var owner:Fur;
		public var ongoing:Boolean = false;
		
		/// The 'tags' associated with this event; ex, moderate-popularity art is: "Art": 0.5
		public var attributes:Object;
		
		/// The EventCell associated with this event.
		public var uiBlock:MovieClip;
		
		/**
		 * Constructor. Also adds self to the given owner's ownedEvents.
		 * @param	name_			player-visible name of event, e.g. "Opening Ceremony"
		 * @param	duration_		duration in minutes
		 * @param	owner_			Fur who owns the event
		 * @param	attributes_
		 */
		public function ConEvent(name_:String, duration_:int, owner_:Fur, attributes_:Object = null) {
			name = name_;
			duration = duration_;
			owner = owner_;
			owner.ownedEvents.push(this);
			owner.mc_object.gotoAndStop(2);		// temp dev code; change color to red
			// replace default special logic with owner logic
			owner.brain["special"] = new LogicSP_Owner(owner);
			
			attributes = attributes_;
			if (attributes == null) {
				attributes = { };
			} else {
				if (attributes["ongoing"]) {
					ongoing = true;
				}
			}
		}
		
		/**
		 * For a given set of interests, returns how desirable this event is, [0.0-1.0]
		 * @param	interests	Fur interests
		 * @return				Desirability rating [0.0-1.0]
		 */
		public function getDesirability(interests:Object):Number {
			var interestRatings:Array = [];
			// what to score an attribute this event has, but the Fur doesn't have
			const INTEREST_AMBIVALENT:Number = 0.35;
			for (var attribute:String in attributes) {
				// if the Fur has an opinion on this event attribute
				if (interests[attribute] != null) {
					// ease of being interested in an event; e.g. 1.0 means any art event (>=0.0) will elicit interest
					var opinion:Number = interests[attribute];
					// how niche the event is; e.g. a mainstream event with 0.7 yields 0.3 attRating, meaning Furs with
					//	an opinion rating of >=0.3 will be 100% interested
					var attRating:Number = 1 - attributes[attribute];
					// if fur opinion meets or exceeds event rating, push 1.0
					if (opinion >= attRating) {
						interestRatings.push(1);
					// otherwise, subtract 300% the difference in event rating and fur opinion from 1.0 and push that,
					//	or 0.0 if it's negative
					} else {
						interestRatings.push(Math.max(0, (1 - 3 * (attRating - opinion))));
					}
				// otherwise, handle special attributes, or push ambivalent
				} else {
					switch (attribute) {
						case "Main Event":
							interestRatings.push(System.getRandNum(.3, 1));		// TODO improve
							break;
						default:
							interestRatings.push(INTEREST_AMBIVALENT);
					}
				}
			}
			// TODO more sophisticated method of desirability
			return System.calculateAverage(interestRatings);
		}
		
		/**
		 * Schedule the event at the given time and place.
		 * (Makes no assumptions about conflicts.)
		 * @param 	room_
		 * @param	day_
		 * @param	startHour_
		 * @param	startMinute_
		 */
		public function scheduleEvent(room_:ConRoom, day_:String, startHour_:int, startMinute_:int):void {
			room = room_;
			day = day_;
			startHour = startHour_;
			startMinute = startMinute_;
			var endTime:Array = System.fromTimestamp(System.toTimestamp(startHour, startMinute) + duration);
			endHour = endTime[0];
			endMinute = endTime[1];
		}
		
		/**
		 * Returns true if this event has a valid room, day, and time.
		 * @return
		 */
		public function isScheduled():Boolean {
			return room != null && day != null && startHour != -1 && startMinute != -1 && endHour != -1 && endMinute != -1;
		}
		
		/**
		 * Resets time and room info.
		 */
		public function resetEvent():void {
			room = null;
			day = null;
			startHour = -1;
			startMinute = -1;
			endHour = -1;
			endMinute = -1;
		}
		
		public function getTimestamp(isStart:Boolean):int {
			return isStart ? System.toTimestamp(startHour, startMinute) :
							 System.toTimestamp(endHour, endMinute);
		}
		
		/**
		 * Checks if the given ConEvent conflicts with this one
		 * @param	otherEvent
		 * @return
		 */
		public function isConflicting(otherEvent:ConEvent):Boolean {
			if (otherEvent.day != this.day || otherEvent.room != this.room) {
				return false;
			}
			return getTimestamp(true) < otherEvent.getTimestamp(false) &&
				   getTimestamp(false) > otherEvent.getTimestamp(true);
		}
		
		/**
		 * Return 1-liner info about this event.
		 * @return
		 */
		public function debugEvent():String {
			return day + " (" + startHour + ":" + System.pad(startMinute) + ") to (" +
			endHour + ":" + System.pad(endMinute) + ") [" + room.name + "] " + name;
		}
	}
}