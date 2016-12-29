package src.cobaltricindustries.fct.support.graph {
	import src.cobaltricindustries.fct.support.conevent.ConRoom;
	/**
	 * Helps define the hotel's rooms.
	 * @author Serule Blue
	 */
	public class Hotel {
		public var name:String = "The Harriot";
		/// Dictionary of room names to rooms.
		public var rooms:Object;
		
		public function Hotel(name_:String) {
			name = name_;
			rooms = { };
			
			switch (name) {
				case "The Harriot":
					rooms["Ballroom"] = new ConRoom("Ballroom", null, null);
					break;
			}
		}
	}
}