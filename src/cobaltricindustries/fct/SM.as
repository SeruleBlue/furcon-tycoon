package src.cobaltricindustries.fct {
	/**
	 * State Machine constants.
	 * @author Serule Blue
	 */
	public class SM {
		private static var enum:int = 0;

		public static const STATE_IDLE:int = enum++;
		public static const STATE_STUCK:int = enum++;
		public static const STATE_MOVE_FREE:int = enum++;
		public static const STATE_MOVE_NETWORK:int = enum++;
		public static const STATE_MOVE_FROM_NETWORK:int = enum++;
		public static const STATE_IN_EVENT:int = enum++;

		public function SM() {
			// Do not instiantiate.
		}
		
		/**
		 * Convert a SM state to a human-readable state.
		 * @param	enum
		 * @return
		 */
		public static function enumToString(enum:int):String {
			switch (enum) {
				case STATE_IDLE:
					return "Idling";
				case STATE_STUCK:
					return "Stuck";
				case STATE_MOVE_FREE:
				case STATE_MOVE_NETWORK:
				case STATE_MOVE_FROM_NETWORK:
					return "Walking";
				case STATE_IN_EVENT:
					return "In an event";
			}
			return "Unknown";
		}
	}
}