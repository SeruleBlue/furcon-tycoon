package src.cobaltricindustries.fct.props.actor.logic {
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.props.ABST_Movable;
	import flash.geom.Point;
	
	/**
	 * Simple movement to a given point, using the path network.
	 * @author Serule Blue
	 */
	public class LogicMove extends ABST_Logic {
	
		public static const BEELINE_INTERVAL:int = 15;	// how often to check for beeline
		protected var beelineCounter:int = System.getRandInt(0, BEELINE_INTERVAL);

		public function LogicMove(fur_:Fur) {
			super(fur_);
		}	
		
		override public function runLogic(...args):void {
			switch (fur.state) {
				case ABST_Movable.STATE_MOVE_NETWORK:
					if (fur.pointOfInterest != null) {
						if (++beelineCounter >= BEELINE_INTERVAL) {
							beelineCounter = 0;
							// Check if we can make a beeline to the target.
							if (System.inRange(fur.mc_object.x, fur.mc_object.y, fur.pointOfInterest.x, fur.pointOfInterest.y, ABST_Movable.BEELINE_RANGE) &&
								System.extendedLOScheck(fur, fur.pointOfInterest)) {
								gotoTarget();
								break;
							// Check if we can make a beeline to the next node.
							} else if (fur.path.length > 0 &&
									   System.inRangeMc(fur.mc_object, fur.path[0].mc_object, ABST_Movable.BEELINE_RANGE) &&
									   System.extendedLOScheck(fur, new Point(fur.path[0].mc_object.x, fur.path[0].mc_object.y))) {
								gotoNextNode();
								break;
							}
						}
					}
					if (fur.nodeOfInterest == null) {
						fur.state = ABST_Movable.STATE_MOVE_FROM_NETWORK;
						return;
					}
					fur.moveToPoint(new Point(fur.nodeOfInterest.mc_object.x, fur.nodeOfInterest.mc_object.y));
					// arrived at next node	
					if (System.inRangeMc(fur.mc_object, fur.nodeOfInterest.mc_object, ABST_Movable.RANGE)) {
						gotoNextNode();
					}
					break;
				case ABST_Movable.STATE_MOVE_FROM_NETWORK:
					fur.moveToPoint(fur.pointOfInterest);
					// arrived at destination
					if (System.inRange(fur.mc_object.x, fur.mc_object.y, fur.pointOfInterest.x, fur.pointOfInterest.y, fur.range)) {
						fur.nodeOfInterest = null;
						fur.pointOfInterest = null;
						fur.state = ABST_Movable.STATE_IDLE;
						// Get ready to immediately check for beeline the next time we need to move.
						beelineCounter = BEELINE_INTERVAL;
					}
					break;
			}
		}
		
		/**
		 * Proceed to the target.
		 */
		protected function gotoTarget():void {
			fur.state = ABST_Movable.STATE_MOVE_FROM_NETWORK;
			fur.path = [];
			fur.nodeOfInterest = null;
		}
		
		/**
		 * Proceed to the next node in the path. Switch to STATE_MOVE_FROM_NETWORK if the path is done.
		 */
		protected function gotoNextNode():void {
			fur.nodeOfInterest = fur.path.shift();
			if (fur.nodeOfInterest == null) {
				fur.state = ABST_Movable.STATE_MOVE_FROM_NETWORK;
			}
		}
	}
}