package src.cobaltricindustries.fct.support {
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import src.freeactionscript.Scrollbar;
	import flash.display.MovieClip;
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
		
		/// A map of event names to events
		public var events:Object;
		
		/// A map of room names to rooms
		public var rooms:Object;
		private var roomsArr:Array;
		/// A map of room names to index in roomsArr
		private var roomToIndex:Object;
		
		public var currentEvents:Array = []
		public var upcomingEvents:Array = [];
		
		// UI helpers -----------------------------------------------------
		/// Pre-placed stage instance of SWC_ScheduleCell for use as a reference.
		private var anchor:MovieClip;
		private var sched:MovieClip;
		private var inner:MovieClip;
		/// A 2D array of SWC_ScheduleCells. Indexed by column, then row.
		private var scheduleCells:Array;
		private var scrollbarVertical:Scrollbar;
		
		private const MIBS:Array = [60, 30, 15];
		private var mibsInd:int = 0;
		/// How many minutes per UI block.
		private var minsInBlock:int = MIBS[mibsInd];

		public function Schedule(cg_:ContainerGame, hotel:Hotel) {
			super(cg_);
			rooms = hotel.rooms;
			roomsArr = [];
			for each (var cr:ConRoom in rooms) {
				roomsArr.push(cr);
			}
			roomsArr = roomsArr.sort();
			roomToIndex = { };
			for (var i:int = 0; i < roomsArr.length; i++) {
				roomToIndex[roomsArr[i].name] = i;
			}
			
			// Temp dev code only!
			events = { };
			events["Opening Ceremony"] = new ConEvent("Opening Ceremony", 30);
			events["Artist Alley"] = new ConEvent("Artist Alley", 60);
			events["Art Panel"] = new ConEvent("Art Panel", 30);
			events["Dealer's Den"] = new ConEvent("Dealer's Den", 30);
			
			scheduleEvent(events["Opening Ceremony"], rooms["Ballroom"], "Tue", 10, 0);
			scheduleEvent(events["Artist Alley"], rooms["Panel 3"], "Tue", 11, 30);
			scheduleEvent(events["Dealer's Den"], rooms["Ballroom"], "Tue", 13, 0);
			scheduleEvent(events["Art Panel"], rooms["Panel 3"], "Tue", 13, 0);
			//debugSchedule();
			// end dev code
			
			buildScheduleUi();
			updateZoomButtons();
			updateEvents();
		}
		
		override public function step():void {
			if (sched.visible) {
				inner.mc_currentTime.y = anchor.y + (anchor.height * (cg.time.getCurrentTimestamp() / minsInBlock));
			}
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
		
		/**
		 * Re-draw the event blocks.
		 */
		public function updateEvents():void {
			for each (var ce:ConEvent in events) {
				// create a new one if needed
				if (ce.isScheduled()) {
					if (ce.uiBlock == null) {
						ce.uiBlock = new SWC_EventCell();
						ce.uiBlock.tf_event.text = ce.name;
						// TODO color
						//ce.uiBlock.mc_box.transform.colorTransform = new ColorTransform(1, 1, 1);
					}
					inner.addChild(ce.uiBlock);
				}
				// update the position
				ce.uiBlock.x = anchor.x + (anchor.width * (roomToIndex[ce.room.name] + 1));
				ce.uiBlock.y = anchor.y + (anchor.height * (ce.getTimestamp(true) / minsInBlock));
				ce.uiBlock.mc_box.scaleY = ce.duration / minsInBlock;
			}
		}

		/**
		 * Set up the schedule UI. Should be called once at the start of the game only.
		 */
		public function buildScheduleUi():void {
			sched = cg.game.mc_ui.mc_schedule;
			inner = sched.mc_innerSchedule;
			anchor = inner.mc_anchor;
			anchor.visible = false;
			
			scheduleCells = [];
			// build 1 column per room, plus 1 for the time legend
			for (var c:int = 0; c <= roomsArr.length; c++) {
				var column:Array = [];
				// build the maximum amount of cells for the highest zoom level, plus 1 for the room legend
				for (var r:int = 0; r <= (60 / MIBS[MIBS.length - 1]) * 24; r++) {
					var cell:MovieClip = new SWC_ScheduleCell();
					// topmost row
					if (r == 0) {
						cell.gotoAndStop("extended");
						if (c != 0) {
							cell.tf_cell.text = roomsArr[c - 1].name;
						} else {
							cell.tf_cell.visible = false;
						}
					// hide extra cells to be used if the time is zoomed in
					} else if (r > (60 / minsInBlock) * 24) {
						cell.visible = false;
						cell.tf_cell.visible = false;
					// not building the time column
					} else if (c != 0) {
						cell.tf_cell.visible = false;
					} else {
						cell.tf_cell.text = Time.getFormattedTime(r - 1, 0);
					}
					cell.x = anchor.x + c * anchor.width;
					cell.y = anchor.y + r * anchor.height;
					// only add the child if needed, to ensure scrollbar works properly
					if (cell.visible) {
						inner.addChild(cell);
					}
					column.push(cell);
				}
				scheduleCells.push(column);
			}
			
			// Initialize the scrollbars.
			scrollbarVertical = new Scrollbar();
			scrollbarVertical.init(inner, sched.mc_scheduleMask, sched.mc_trackVert, sched.mc_sliderVert);
			
			// Initialize other buttons.
			sched.btn_close.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				cg.game.mc_ui.mc_schedule.visible = false;
			});
			var zoomIn:Function = zoom(true);
			var zoomOut:Function = zoom(false);
			sched.btn_zoomIn.addEventListener(MouseEvent.CLICK, zoomIn);
			sched.btn_zoomOut.addEventListener(MouseEvent.CLICK, zoomOut);
		}
		
		/**
		 * Update the schedule based on zoom level.
		 */
		private function rebuildScheduleUi():void {
			var cell:MovieClip;
			for (var c:int = 0; c <= roomsArr.length; c++) {
				for (var r:int = 0; r < scheduleCells[c].length; r++) {
					cell = scheduleCells[c][r];
					// update time cells
					if (c == 0 && r >= 1 && r <= (60 / minsInBlock) * 24) {
						var raw:Number = (r - 1) * (minsInBlock) / 60;
						var h:int = int(raw);
						var m:int = 60 * (raw - h);
						cell.tf_cell.visible = true;
						cell.tf_cell.text = Time.getFormattedTime(h, m);
					}
					// hide extra cells
					if (r > (60 / minsInBlock) * 24) {
						cell.visible = false;
						if (inner.contains(cell)) {
							inner.removeChild(cell);
						}
					} else {
						cell.visible = true;
						if (!inner.contains(cell)) {
							inner.addChild(cell);
						}
					}
				}
			}
			updateEvents();
		}
		
		/**
		 * Change the zoom of the schedule.
		 * @param	zoomIn	true to zoom in, false to zoom out
		 */
		private function zoom(zoomIn:Boolean):Function {
			return function(e:MouseEvent):void {
				if (zoomIn && mibsInd + 1 == MIBS.length) {
					return;
				} else if (!zoomIn && mibsInd - 1 < 0) {
					return;
				}
				mibsInd += zoomIn ? 1 : -1;
				minsInBlock = MIBS[mibsInd];
				updateZoomButtons();
				rebuildScheduleUi();
			}
		}
		
		private function updateZoomButtons():void {
			sched.btn_zoomIn.alpha = mibsInd == MIBS.length - 1 ? .25 : 1;
			sched.btn_zoomOut.alpha = mibsInd == 0 ? .25 : 1;
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