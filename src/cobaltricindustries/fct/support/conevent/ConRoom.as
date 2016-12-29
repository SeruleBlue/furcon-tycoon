package src.cobaltricindustries.fct.support.conevent {
	import flash.display.MovieClip;
	/**
	 * Represents a room in the hotel.
	 * @author Alexander Huynh
	 */
	public class ConRoom {
		/// The name of the room.
		public var name:String = "Untitled Room";
		/// The MovieClip in the game representing the room.
		public var mc_room:MovieClip;
		/// If the room is rectangular, to use less expensive pathplanning.
		public var isRectangle:Boolean;
		/// List of GraphNodes associated with this room.
		public var roomNodes:Array;
		/// Dictionary of timestamp to scheduled ConEvents for this room.
		public var conEvents:Object;
		
		/// Maximum number of Furs allowed in this room. ('allowed' for gameplay purposes, not technically)
		public var maxCapacity:int = 100;
		
		public function ConRoom(name_:String, mc_room_:MovieClip, roomNodes_:Array, isRectangle_:Boolean = true) {
			name = name_;
			mc_room = mc_room_;
			roomNodes = roomNodes_;
			isRectangle = isRectangle_;
			
			conEvents = { };
		}

		/**
		 * Tries to schedule the given ConEvent.
		 * If there is a conflict, the event will be rejected.
		 * @param	ce	the ConEvent to schedule, with data already set
		 * @return	true if no conflicts
		 */
		public function scheduleConEvent(ce:ConEvent):Boolean {
			for each (var otherEvent:ConEvent in conEvents) {
				if (ce.isConflicting(otherEvent)) {
					return false;
				}
			}
			conEvents[ce.getTimestamp(true)] = ce;
			return true;
		}
	}
}