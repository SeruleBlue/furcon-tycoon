package src.cobaltricindustries.fct.props {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.support.graph.GraphNode;
	import src.cobaltricindustries.fct.System;
	
	/**
	 * Object that can move inside the hotel.
	 * @author Serule Blue
	 */
	public class ABST_Movable extends ABST_Object {
		private const NORMAL_SPEED:Number = 2;
		private const PRECISE_SPEED:Number = 0.75;
		
		private var range:Number = 5;			// current range
		private const RANGE:Number = 5;			// node clear range
		private const MOVE_RANGE:Number = 2;	// diff on movement
		
		private var enum:int = 0;
		
		private var state:int;
		private const STATE_IDLE:int = enum++;
		private const STATE_STUCK:int = enum++;
		private const STATE_MOVE_FREE:int = enum++;
		private const STATE_MOVE_NETWORK:int = enum++;
		private const STATE_MOVE_FROM_NETWORK:int = enum++;

		public var hitMask:MovieClip;
		
		private var pointOfInterest:Point;
		/// Goal GraphNode.
		private var nodeOfInterest:GraphNode;
		/// Ordered list of GraphNodes to visit to get to the nodeOfInterest.
		private var path:Array;

		public function ABST_Movable(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip) {
			super(_cg, _mc_object);
			hitMask = _hitMask;
			
			state = STATE_IDLE;
		}
		
		override public function step():Boolean {			
			switch (state) {
				case STATE_IDLE:
					if (nodeOfInterest == null) {
						nodeOfInterest = System.getRandFrom(cg.graphMaster.nodes);
						setPOI(new Point(nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y));
						trace('[ABST_Object] Moving to new nodeOfInterest: ' + nodeOfInterest.mc_object.name);
					}
				break;
				case STATE_MOVE_NETWORK:
					if (nodeOfInterest == null) {
						trace("[" + this + "] Node of interest was null! Cancelling!");
						state = STATE_MOVE_FROM_NETWORK;
						return completed;
					}
					moveToPoint(new Point(nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y));
					// arrived at next node	
					if (System.getDistance(mc_object.x, mc_object.y, nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y) < RANGE) {
						nodeOfInterest = path.shift();
						if (nodeOfInterest == null) {
							trace("[" + this + "] Leaving path network.");
							state = STATE_MOVE_FROM_NETWORK;
							return completed;
						}
					}
				break;
				case STATE_MOVE_FROM_NETWORK:
					moveToPoint(pointOfInterest);
					// arrived at destination
					if (System.getDistance(mc_object.x, mc_object.y, pointOfInterest.x, pointOfInterest.y) < range) {
						trace("[" + this + "] Arrived!");
						nodeOfInterest = null;
						state = STATE_IDLE;
					}
				break;
			}
			
			
			return false;
		}
		
		/**
		 * Set the POI and calculate a new path
		 * @param	p		new POI
		 */
		private function setPOI(p:Point):void {
			pointOfInterest = p;
			path = cg.graphMaster.getPath(this, pointOfInterest);
			if (path.length != 0) {
				nodeOfInterest = path[0];
			}	
			range = RANGE;
			state = STATE_MOVE_NETWORK;
			trace("[" + this + "] New path found of length: " + path.length);
		}

		override protected function updatePosition(dx:Number, dy:Number):void {
			var ptNew:Point = new Point(mc_object.x + dx, mc_object.y + dy);
			if (isPointValid(ptNew)) {
				mc_object.x = ptNew.x;
				mc_object.y = ptNew.y;
			}
			else {
				onCollision();
			}
		}
		
		/**
		 * Actions to perform when this object collides with the hotel's hitbox
		 */
		protected function onCollision():void {
			// -- override this function
		}
		
		/**
		 * Determines if the given point is colliding with the hotel
		 * @param	pt		The point to check
		 * @return			true if the point is colliding with the hotel
		 */
		public function isPointValid(pt:Point):Boolean {			
			var ptL:Point = MovieClip(mc_object.parent).localToGlobal(pt);
			return !(mc_object.hitTestObject(hitMask) && hitMask.hitTestPoint(ptL.x, ptL.y, true));
		}
		
		/**
		 * Takes a step to the given target.
		 * @param	tgt
		 */
		public function moveToPoint(tgt:Point):void {
			var moveSpeedX:Number;
			var moveSpeedY:Number;
			if (Math.abs(mc_object.x - tgt.x) < NORMAL_SPEED)
				moveSpeedX = PRECISE_SPEED;
			else
				moveSpeedX = NORMAL_SPEED;
			if (Math.abs(mc_object.y - tgt.y) < NORMAL_SPEED)
				moveSpeedY = PRECISE_SPEED;
			else
				moveSpeedY = NORMAL_SPEED;
				
			var dX:Number = 0;
			var dY:Number = 0;
			
			if (mc_object.y > tgt.y + MOVE_RANGE) {
				dY = -moveSpeedY;
			} else if (mc_object.y < tgt.y - MOVE_RANGE) {
				dY = moveSpeedY;
			}
			if (mc_object.x < tgt.x - MOVE_RANGE) {
				dX = moveSpeedX;
			} else if (mc_object.x > tgt.x + MOVE_RANGE) {
				dX = -moveSpeedX;
			}
			
			updatePosition(dX, dY);
		}
	}
}