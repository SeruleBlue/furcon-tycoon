package src.cobaltricindustries.fct.support.conevent {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import src.cobaltricindustries.fct.support.graph.GraphNode;
	import src.cobaltricindustries.fct.System;
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
		 * Returns the next event happening in this room within maxDistance minutes. Ignores current events.
		 * @param	timestamp		current time to look from
		 * @param	maxDistance		maximum time from now to return an event for
		 * @return					the next ConEvent in this room for the given parameters
		 */
		public function getNextEvent(timestamp:int, maxDistance:int = 60):ConEvent {
			var closest:ConEvent;
			var closestTime:int = maxDistance + 1;
			var compareTime:int = timestamp + maxDistance;
			for each (var ce:ConEvent in conEvents) {
				var eventTime:int = ce.getTimestamp(true);
				// event start has already passed, ignore
				if (timestamp >= eventTime) {
					continue;
				}
				// event is too far in the future
				if (compareTime < eventTime) {
					continue;
				}
				var diff:int = timestamp - eventTime;
				if (closest == null || diff < closestTime) {
					closest = ce;
					closestTime = diff;
				}
			}
			return closest;
		}
		
		/**
		 * Returns any Point in this Event.
		 * @return
		 */
		public function getCoordinateLocation():Point {
			if (isRectangle) {
				return System.getRandomValidLocationInRoom(mc_room);
			}
			if (roomNodes == null) {
				trace("[ConRoom  " + name + "] WARNING: Room has no nodes.");
				return new Point();
			}
			var mc:MovieClip = System.getRandFrom(roomNodes).mc_object;
			return new Point(mc.x, mc.y);
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