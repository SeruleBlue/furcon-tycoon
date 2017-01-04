package src.cobaltricindustries.fct.props {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.support.graph.GraphNode;
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.support.Time;
	import src.cobaltricindustries.fct.SM;
	
	/**
	 * Object that can move inside the hotel.
	 * @author Serule Blue
	 */
	public class ABST_Movable extends ABST_Object {
		public static const NORMAL_SPEED:Number = 2;
		public static const PRECISE_MULT:Number = 0.4;
		public var speed:Number = NORMAL_SPEED;
		
		public var range:Number = 10;					// current range
		public static const RANGE:Number = 5;			// node clear range
		public static const MOVE_RANGE:Number = 2;		// diff on movement
		public static const BEELINE_RANGE:Number = 300;	// max distance from target to consider making a beeline
		
		/// One of SM.STATE variables.
		public var state:int;

		public var hitMask:MovieClip;
		
		public var pointOfInterest:Point;
		/// Goal GraphNode.
		public var nodeOfInterest:GraphNode;
		/// Ordered list of GraphNodes to visit to get to the nodeOfInterest.
		public var path:Array;
		
		public var debuggingEnabled:Boolean = false;
		public var debugMc:MovieClip;

		public function ABST_Movable(_cg:ContainerGame, _mc_object:MovieClip, _hitMask:MovieClip) {
			super(_cg, _mc_object);
			hitMask = _hitMask;
			
			state = SM.STATE_IDLE;
			
			mc_object.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			mc_object.removeEventListener(Event.ADDED_TO_STAGE, init);
			mc_object.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected function onClick(e:MouseEvent):void {
		}
		
		override public function step():Boolean {
			if (debuggingEnabled) {
				handleDebug();
			}		
			return false;
		}
		
		/**
		 * Set the POI and calculate a new path. Sets state to STATE_MOVE_NETWORK.
		 * @param	p		new POI
		 * @param	noPath	if true, don't calculate a path
		 */
		public function setPOI(p:Point, noPath:Boolean = false):void {
			pointOfInterest = p;
			path = [];
			if (!noPath) {
				path = cg.graphMaster.getPath(this, pointOfInterest);
				if (path.length != 0) {
					nodeOfInterest = path[0];
				}
				state = SM.STATE_MOVE_NETWORK;
			} else {
				state = SM.STATE_MOVE_FROM_NETWORK;
			}
			range = RANGE;
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
			var spd:Number = speed * (System.getDistance(mc_object.x, mc_object.y, tgt.x, tgt.y) < RANGE ? PRECISE_MULT : 1);
			var tgtAngle:Number = System.getAngle(mc_object.x, mc_object.y, tgt.x, tgt.y);
			updatePosition(System.forward(spd, tgtAngle, true), System.forward(spd, tgtAngle, false));
		}
		
		/**
		 * Create debug drawing support objects.
		 */
		public function enableDebugging():void {
			debuggingEnabled = true;
			debugMc = new MovieClip();
			cg.game.addChild(debugMc);			
		}
		
		/**
		 * Draw debugging information. Requires enableDebugging to be called once prior.
		 */
		private function handleDebug():void {
			if (Time.isKeyframe()) {
				debugMc.graphics.clear();
				if (nodeOfInterest != null) {
					debugMc.graphics.lineStyle(2, 0x0000FF, 0.25);
					debugMc.graphics.moveTo(mc_object.x, mc_object.y);
					debugMc.graphics.lineTo(nodeOfInterest.mc_object.x, nodeOfInterest.mc_object.y);
				}
				if (pointOfInterest != null) {
					debugMc.graphics.lineStyle(2, 0xFF0000, 0.25);
					debugMc.graphics.moveTo(mc_object.x, mc_object.y);
					debugMc.graphics.lineTo(pointOfInterest.x, pointOfInterest.y);
				}
				if ((this is Fur) && (this as Fur).eventOfInterest != null) {
					debugMc.graphics.lineStyle(4, 0x00FF00, 0.25);
					debugMc.graphics.moveTo(mc_object.x, mc_object.y);
					debugMc.graphics.lineTo((this as Fur).eventOfInterest.room.mc_room.x, (this as Fur).eventOfInterest.room.mc_room.y);
				}
			}
		}
	}
}