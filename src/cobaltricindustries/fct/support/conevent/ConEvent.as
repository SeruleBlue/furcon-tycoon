package src.cobaltricindustries.fct.support.conevent {
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.System;
	/**
	 * A single event in the con.
	 * @author Serule Blue
	 */
	public class ConEvent {
		public var name:String;
		/// Length of the event in minutes, [start, end)
		public var duration:int;
		
		public var room:ConRoom;
		public var day:String;
		public var startHour:int = -1;
		public var startMinute:int = -1;
		public var endHour:int = -1;
		public var endMinute:int = -1;
		
		/// The EventCell associated with this event.
		public var uiBlock:MovieClip;
		
		public function ConEvent(name_:String, duration_:int) {
			name = name_;
			duration = duration_;
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