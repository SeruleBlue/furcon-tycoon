package src.cobaltricindustries.fct.managers {
	import flash.geom.Point;
	import src.cobaltricindustries.fct.ContainerGame;
	import src.cobaltricindustries.fct.props.actor.Fur;
	import src.cobaltricindustries.fct.System;
	import src.cobaltricindustries.fct.support.Demographics;
	/**
	 * Updates all Furs and provides aggregated stats.
	 * @author Serule Blue
	 */
	public class ManagerFur extends ABST_Manager {
		
		public function ManagerFur(_cg:ContainerGame) {
			super(_cg);		
			
			// Temporary dev code!
			var fur:Fur;
			for (var i:int = 0; i < 100; i++) {
				fur = new Fur(cg, new SWC_Fur());
				cg.game.mc_containerFurs.addChild(fur.mc_object);
				var pt:Point = System.getRandomValidLocationInRoom(cg.game.mc_innerContainer.rm_ls);
				fur.mc_object.x = pt.x; fur.mc_object.y = pt.y;
				addObject(fur);
				fur.schedule = cg.schedule;
				//fur.enableDebugging();
			}
			
			//debugDemographics();
		}
		
		override public function step():void {
			updateStats();
			super.step();
		}
		
		/**
		 * Update information and report it to the game.
		 */
		public function updateStats():void {
			var stats:Object = { };
			stats["population"] = objArray.length;
			
			// temporary thing
			var rating:int = 0;
			for each (var fur:Fur in objArray) {
				rating += fur.getStat("happiness");
			}
			stats["rating"] = int(rating / objArray.length);
			
			cg.ui.setStats(stats);
		}
		
		/**
		 * Gets demographic information on the Furs currently in this Manager.
		 * @param	stat	name of demographic to look for
		 * @return			Array of [stats, xLabels]. Stats can be a 1 or 2D array. xLabels can be empty.
		 */
		public function getDemographics(stat:String):Array {
			var stats:Array = [];
			var xLabels:Array = [];
			switch (stat) {
				case "Gender":
					stats[0] = [0];	xLabels[0] = ["Male"];
					stats[1] = [0];	xLabels[1] = ["Female"];
					stats[2] = [0];	xLabels[2] = ["Complicated"];
					break;
				case "Interests":
					stats[0] = [];	xLabels[0] = ["Art"];
					stats[1] = [];	xLabels[1] = ["Writing"];
					stats[2] = [];	xLabels[2] = ["Music"];
					stats[3] = [];	xLabels[3] = ["Fursuiting"];
					break;
			}
			var i:int;
			for each (var fur:Fur in objArray) {
				switch (stat) {
					case "Age":
						stats.push(fur.age);
						break;
					case "Money":
						stats.push(fur.stats["money"][0]);
						break;
					case "Gender":
						for (i = 0; i < xLabels.length; i++) {
							if (fur.gender == xLabels[i]) {
								stats[i]++;
								break;
							}
						}
						break;
					case "Interests":
						for (i = 0; i < xLabels.length; i++) {
							stats[i].push(fur.traits[xLabels[i]]);
						}
						break;
				}
			}
			if (stat == "Interests") {
				for (i = 0; i < xLabels.length; i++) {
					if (i == 0) trace("Art coming");
					stats[i] = Demographics.bucketData(stats[i], [0, .2, .4, .6, .8, 1]);
					if (i == 0) trace("Art bucketed:", stats[0]);
				}
			}
			return [stats, xLabels];
		}
		
		/**
		 * Debug output the demographcs of this con's fandom.
		 */
		public function debugDemographics():void {
			var out:String = "[ManagerFur] Demographic Stats\n";
			
			var ages:Array = [];
			var interestsArt:Array = [];
			
			for each (var fur:Fur in objArray) {
				ages.push(fur.age);
				interestsArt.push(fur.traits["Art"]);
			}
			
			ages = ages.sort();
			interestsArt = interestsArt.sort();
			
			out += "[Age Distribution]" + "\n";
			for each (var age:int in ages) {
				out += age + "\n";
			}
			
			out += "[Art Interest Distribution]" + "\n";
			for each (var interestArt:Number in interestsArt) {
				out += interestArt + "\n";
			}
		
			trace(out);
		}
	}
}