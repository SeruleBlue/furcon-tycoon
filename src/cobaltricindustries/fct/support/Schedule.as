package src.cobaltricindustries.fct.support {
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import src.freeactionscript.Scrollbar;
	import flash.display.MovieClip;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.support.ABST_Support;
	import src.cobaltricindustries.fct.support.conevent.ConEvent;
	import src.cobaltricindustries.fct.support.conevent.ConRoom;
	import src.cobaltricindustries.fct.support.graph.Hotel;
	import src.cobaltricindustries.fct.System;
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
		/// The whole schedule MC.
		private var sched:MovieClip;
		/// The inner, masked MC, where cells go.
		private var inner:MovieClip;
		/// Pre-placed stage instance of SWC_ScheduleCell for use as a reference.
		private var anchor:MovieClip;
		/// A 2D array of SWC_ScheduleCells. Indexed by column, then row.
		private var scheduleCells:Array;
		private var scrollbarVertical:Scrollbar;
		
		/// The schedule bank which holds unscheduled events
		private var bank:MovieClip;
		// UI helpers -----------------------------------------------------
		
		
		// Mouse interaction helpers --------------------------------------
		/// Whether the player is currently trying to schedule an event.
		private var isScheduling:Boolean = false;
		private var selectedEvent:ConEvent;
		private var cellLocation:Point;
		private var originalLocation:Point;
		// Mouse interaction helpers --------------------------------------
		
		/// List of all possible values for Minutes In Block
		private const MIBS:Array = [60, 30, 15];
		/// Current index into MIBS.
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
			roomsArr = roomsArr.sort().reverse();
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
			
			/*scheduleEvent(events["Opening Ceremony"], rooms["Ballroom"], "Tue", 8, 30);
			scheduleEvent(events["Artist Alley"], rooms["Panel 3"], "Tue", 8, 45);
			scheduleEvent(events["Dealer's Den"], rooms["Ballroom"], "Tue", 10, 0);
			scheduleEvent(events["Art Panel"], rooms["Panel 3"], "Tue", 10, 0);*/
			//debugSchedule();
			// end dev code
			
			buildScheduleUi();
			updateZoomButtons();
			updateEvents();
		}
		
		override public function step():void {
			// Update the time stripe if the UI is open.
			if (sched.visible) {
				inner.mc_currentTime.y = anchor.y + (anchor.height * (cg.time.getCurrentTimestamp() / minsInBlock));
			}
			if (isScheduling) {
				handleScheduling();
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
		 * Create and relocate the event blocks as necessary.
		 */
		public function updateEvents():void {
			var i:int = 0;
			for each (var ce:ConEvent in events) {
				// create a new one if needed
				if (ce.uiBlock == null) {
					ce.uiBlock = new SWC_EventCell();
					ce.uiBlock.tf_event.text = ce.name;
					// TODO color
					//ce.uiBlock.mc_box.transform.colorTransform = new ColorTransform(1, 1, 1);
					var onEventBlockL:Function = onEventBlock(ce);
					ce.uiBlock.addEventListener(MouseEvent.CLICK, onEventBlockL);
				}
				// put in schedule if scheduled
				if (ce.isScheduled()) {
					if (!inner.contains(ce.uiBlock)) {
						inner.addChild(ce.uiBlock);
					}
					// update the position
					ce.uiBlock.x = anchor.x + (anchor.width * (roomToIndex[ce.room.name] + 1));
					ce.uiBlock.y = anchor.y + (anchor.height * (ce.getTimestamp(true) / minsInBlock));
					// subtract 5 to accomodate for the bottom buffer
					ce.uiBlock.mc_box.height = anchor.height * (ce.duration / minsInBlock) - 5;
				// put in bank if unscheduled
				} else {
					if (!bank.contains(ce.uiBlock)) {
						bank.addChild(ce.uiBlock);
					}
					ce.uiBlock.x = bank.mc_anchorEvent.x + ((ce.uiBlock.width + 15) * i++);
					ce.uiBlock.y = bank.mc_anchorEvent.y;
					ce.uiBlock.mc_box.height = anchor.height * (ce.duration / minsInBlock) - 5;
				}
			}
		}
		
		/**
		 * Called when a ConEvent is clicked. Schedule or unschedule this event.
		 * @param	ce	the ConEvent that was clicked
		 * @return
		 */
		private function onEventBlock(ce:ConEvent):Function {
			return function(e:MouseEvent):void {
				// event was clicked in the bank; switch to scheduling mode
				if (!isScheduling && bank.visible) {
					isScheduling = true;
					selectedEvent = ce;
					bank.visible = false;
					sched.mc_placing.visible = true;
					sched.mc_placing.addEventListener(MouseEvent.CLICK, stopPlacement);
					if (bank.contains(ce.uiBlock)) {
						bank.removeChild(ce.uiBlock);
					}
					if (!inner.contains(ce.uiBlock)) {
						inner.addChild(ce.uiBlock);
					}
					ce.uiBlock.alpha = .5;
					originalLocation = new Point(ce.uiBlock.x, ce.uiBlock.y);
				// event is being placed in the schedule
				} else if (isScheduling) {
					var room:ConRoom = roomsArr[cellLocation.x - 1];
					var time:int = cellLocation.y * 60 * (MIBS[mibsInd] / 60) - MIBS[mibsInd];
					var hm:Array = System.fromTimestamp(time);
					if (scheduleEvent(selectedEvent, room, System.DAYS[cg.time.day], hm[0], hm[1])) {
						stopPlacement();
					}
				}
			}
		}
		
		/**
		 * Cancels placement of an event.
		 * @param	e
		 */
		private function cancelPlacement(e:MouseEvent):void {
			selectedEvent.uiBlock.x = originalLocation.x;
			selectedEvent.uiBlock.y = originalLocation.y;
			stopPlacement();
		}
		
		/**
		 * Called by clicking outside of the schedule when attempting to schedule an event,
		 * or if the event was successfully scheduled.
		 */
		private function stopPlacement():void {
			sched.mc_placing.removeEventListener(MouseEvent.CLICK, stopPlacement);
			selectedEvent.uiBlock.alpha = 1;
			selectedEvent = null;
			isScheduling = false;
			originalLocation = null;
			sched.mc_placing.visible = false;
		}
		
		private function handleScheduling():void {
			// ghost the event over the nearest cell
			var m:Point = new Point(cg.mouseX + System.GAME_HALF_WIDTH, cg.mouseY + System.GAME_HALF_HEIGHT);
			if (cg.didMouseUpdate()) {
				var hoverCell:MovieClip;
				for (var c:int = 1; c < scheduleCells.length; c++) {
					for (var r:int = 1; r <= (60 / MIBS[mibsInd]) * 24 + 1; r++) {
						var cell:MovieClip = scheduleCells[c][r];
						var cp:Point = cell.localToGlobal(new Point());
						if (!System.outOfBounds(m.x, cp.x, cp.x + cell.width) &&
							!System.outOfBounds(m.y, cp.y - cell.height, cp.y)) {
							hoverCell = cell;
							cellLocation = new Point(c, r);
							break;
						}
					}
				}
				if (hoverCell != null) {
					selectedEvent.uiBlock.visible = true;
					selectedEvent.uiBlock.x = hoverCell.x;
					selectedEvent.uiBlock.y = hoverCell.y - hoverCell.height;
				} else {
					selectedEvent.uiBlock.visible = false;
					cellLocation = null;
				}
			}
		}

		/**
		 * Set up the schedule UI. Should be called once at the start of the game only.
		 */
		public function buildScheduleUi():void {
			sched = cg.game.mc_ui.mc_schedule;
			
			sched.mc_placing.visible = false;
			bank = sched.mc_scheduleBank;
			bank.visible = false;
			bank.mc_anchorEvent.visible = false;
			inner = sched.mc_innerSchedule;
			anchor = inner.mc_anchor;
			anchor.visible = false;
			var anchorOuter:MovieClip = sched.mc_anchorOuter;
			anchorOuter.visible = false;
			
			scheduleCells = [];
			// build 1 column per room, plus 1 for the time legend
			for (var c:int = 0; c <= roomsArr.length; c++) {
				var column:Array = [];
				// build the maximum amount of cells for the highest zoom level, plus 1 for the room legend
				for (var r:int = 0; r <= (60 / MIBS[MIBS.length - 1]) * 24 + 1; r++) {
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
					} else if (r > (60 / minsInBlock) * 25) {
						cell.visible = false;
						cell.tf_cell.visible = false;
					// building the time column
					} else if (c == 0) {
						cell.tf_cell.text = Time.getFormattedTime(r - 1, 0);
					} else {
						cell.tf_cell.visible = false;
					}
					cell.x = anchor.x + c * anchor.width;
					cell.y = anchor.y + r * anchor.height;
					// only add the child if needed, to ensure scrollbar works properly
					if (cell.visible) {
						// special case for pinned top-most row
						if (r == 0) {
							cell.x = anchorOuter.x + c * anchor.width;
							cell.y = anchorOuter.y;
							sched.mc_outerSchedule.addChild(cell);
						} else {
							inner.mc_cellContainer.addChild(cell);
						}
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
			sched.btn_addEvent.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				cg.game.mc_ui.mc_schedule.mc_scheduleBank.visible = true;
			});
			bank.btn_close.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				cg.game.mc_ui.mc_schedule.mc_scheduleBank.visible = false;
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
				for (var r:int = 1; r < scheduleCells[c].length; r++) {
					cell = scheduleCells[c][r];
					// update time cells
					if (c == 0 && r <= (60 / minsInBlock) * 25) {
						var raw:Number = (r - 1) * (minsInBlock) / 60;
						var h:int = int(raw);
						var m:int = 60 * (raw - h);
						cell.tf_cell.visible = true;
						cell.tf_cell.text = Time.getFormattedTime(h, m);
					}
					// hide extra cells
					if (r >= (60 / minsInBlock) * 25) {
						cell.visible = false;
						if (inner.mc_cellContainer.contains(cell)) {
							inner.mc_cellContainer.removeChild(cell);
						}
					} else {
						cell.visible = true;
						if (!inner.mc_cellContainer.contains(cell)) {
							inner.mc_cellContainer.addChild(cell);
						}
					}
				}
			}
			updateEvents();
		}
		
		/**
		 * Attempt to change the zoom of the schedule.
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
		
		/**
		 * Sets the zoom buttons to look enabled or disabled as needed.
		 */
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