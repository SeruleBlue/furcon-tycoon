package src.cobaltricindustries.fct.support {
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.support.ABST_Support;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.support.conevent.ConRoom;
	import src.cobaltricindustries.fct.support.graph.Hotel;
	
	/**
	 * Handles the schedule of events, such as panels and dances.
	 * Currently, the schedule is partitioned into 15-minute blocks.
	 * @author Serule Blue
	 */
	public class Schedule extends ABST_Support {
		
		/// A map of room names to rooms
		public var rooms:Object;
		
		public function Schedule(cg_:ContainerGame, hotel:Hotel) {
			super(cg_);
			rooms = hotel.rooms;
			
			// Temp dev code only!
			var events:Object = { };
			events["Artist Alley"] = new ConEvent("Artist Alley", 60 * 4);
			events["Opening Ceremony"] = new ConEvent("Opening Ceremony", 60);
			events["Art Panel"] = new ConEvent("Art Panel", 90);
			
			scheduleEvent(events["Opening Ceremony"], rooms["Ballroom"], "Tue", 10, 0);
			scheduleEvent(events["Artist Alley"], rooms["Ballroom"], "Tue", 12, 0);
			scheduleEvent(events["Art Panel"], rooms["Ballroom"], "Tue", 16, 0);
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
				//trace("[Schedule] Couldn't schedule event " + event.name);
				return false;
			}
			//trace("[Schedule] Scheduled event " + event.name);
			return true;
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