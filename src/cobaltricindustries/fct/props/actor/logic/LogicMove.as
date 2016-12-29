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
		protected var beelineCounter:int = 0;

		public function LogicMove(fur_:Fur) {
			super(fur_);
		}	
		
		override public function runLogic(...args):void {
			switch (fur.state) {
				case ABST_Movable.STATE_MOVE_NETWORK:
					if (fur.pointOfInterest != null) {
						// Check if we can make a beeline to the target.
						if (++beelineCounter >= BEELINE_INTERVAL) {
							beelineCounter = 0;
							if (System.getDistance(fur.mc_object.x, fur.mc_object.y, fur.pointOfInterest.x, fur.pointOfInterest.y) < ABST_Movable.BEELINE_RANGE &&
								System.extendedLOScheck(fur, fur.pointOfInterest)) {
								fur.state = ABST_Movable.STATE_MOVE_FROM_NETWORK;
								fur.path = [];
								fur.pathDebug = [];
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
					if (System.getDistance(fur.mc_object.x, fur.mc_object.y, fur.nodeOfInterest.mc_object.x, fur.nodeOfInterest.mc_object.y) < ABST_Movable.RANGE) {
						fur.nodeOfInterest = fur.path.shift();
						if (fur.nodeOfInterest == null) {
							fur.state = ABST_Movable.STATE_MOVE_FROM_NETWORK;
							return;
						}
					}
					break;
				case ABST_Movable.STATE_MOVE_FROM_NETWORK:
					fur.moveToPoint(fur.pointOfInterest);
					// arrived at destination
					if (System.getDistance(fur.mc_object.x, fur.mc_object.y, fur.pointOfInterest.x, fur.pointOfInterest.y) < fur.range) {
						fur.nodeOfInterest = null;
						fur.pointOfInterest = null;
						fur.state = ABST_Movable.STATE_IDLE;
					}
					break;
			}
		}
	}
}