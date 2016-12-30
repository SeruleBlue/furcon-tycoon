package src.cobaltricindustries.fct.support {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.support.ABST_Support;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.support.conevent.ConRoom;
	import src.cobaltricindustries.fct.support.graph.Hotel;
	
	/**
	 * Handles the schedule of events, such as panels and dances.
	 * Currently, the schedule is partitioned into 15-minute blocks.
	 * 
	 * There does not have to be just 1 schedule; a Fur could have a
	 * copy of an out-of-date schedule.
	 * @author Serule Blue
	 */
	public class Schedule extends ABST_Support {
		/// The real schedule.
		public static var masterSchedule:Schedule;
		
		/// A map of room names to rooms
		public var rooms:Object;
		
		public var currentEvents:Array = []
		public var upcomingEvents:Array = [];
		
		public function Schedule(cg_:ContainerGame, hotel:Hotel) {
			super(cg_);
			rooms = hotel.rooms;
			
			// Temp dev code only!
			var events:Object = { };
			events["Opening Ceremony"] = new ConEvent("Opening Ceremony", 30);
			events["Artist Alley"] = new ConEvent("Artist Alley", 60);
			events["Art Panel"] = new ConEvent("Art Panel", 30);
			events["Dealer's Den"] = new ConEvent("Dealer's Den", 30);
			
			scheduleEvent(events["Opening Ceremony"], rooms["Ballroom"], "Tue", 10, 0);
			scheduleEvent(events["Artist Alley"], rooms["Panel 3"], "Tue", 11, 30);
			scheduleEvent(events["Dealer's Den"], rooms["Ballroom"], "Tue", 13, 0);
			scheduleEvent(events["Art Panel"], rooms["Panel 3"], "Tue", 13, 0);
			debugSchedule();
			// end dev code
		}
		
		/**
		 * Schedule the event at the given time in the given room.
		 * @param	event
		 * @param	room
		 * @param	day
		 * @param	startHour
		 * @param	startMinute
		 * @return	true if it was a valid time
		 */
		public function scheduleEvent(event:ConEvent, room:ConRoom, day:String, startHour:int, startMinute:int):Boolean {
			event.scheduleEvent(room, day, startHour, startMinute);
			if (!room.scheduleConEvent(event)) {
				event.resetEvent();
				return false;
			}
			return true;
		}
		
		/**
		 * Gets all of the next events within the next future minutes.
		 * @param	future	how many minutes in the future to look
		 * @return			list of upcoming events
		 */
		public function getUpcomingEvents(future:int = 60):Array {
			var events:Array = [];
			for each (var room:ConRoom in rooms) {
				var event:ConEvent = room.getNextEvent(cg.time.getCurrentTimestamp(), future);
				if (event != null) {
					events.push(event);
				}
			}
			return events;
		}
		
		public function debugSchedule():void {
			var out:String = "[Convention Schedule]\n";
			for each (var room:ConRoom in rooms) {
				for each (var event:ConEvent in room.conEvents) {
					out += "\t" + event.debugEvent() + "\n";
				}
			}
			trace(out);
		}
	}
}