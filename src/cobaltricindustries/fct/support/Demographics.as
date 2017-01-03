package src.cobaltricindustries.fct.support {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import src.cobaltricindustries.fct.ContainerGame;
	import flash.events.MouseEvent;
	import src.cobaltricindustries.fct.managers.ManagerFur;
	
	/**
	 * Demographics window. Visualizes demographics about the con attendees.
	 * See FurDesigner for Demographic generation.
	 * @author Serule Blue
	 */
	public class Demographics extends ABST_Support {
		
		private var demo:MovieClip;
		private var graph:MovieClip;
		private var mf:ManagerFur;
		
		/// The current demographic stat, such as "Age".
		private var stat:String;
		
		/// List of x and y axis SWC_ChartLabels.
		private var labels:Array = [];
		
		/// Map of title to [xaxis, yaxis] labels
		public const titleToAxis:Object = {
			"Age": ["Age", "Furs"],
			"Gender": ["Biological Gender", "Furs"],
			// these shouldn't really be used other than for testing
			"Money": ["Cash on Hand", "Furs"]
		}
		
		/// Where to start the graph
		private const ANCHOR:Point = new Point(40, -40);
		/// Max x and y size of the graph
		private const MAX_SIZES:Point = new Point(450, 350);
		/// What % of the bar to use as buffer between bars
		private const BUFFER_PROPORTION:Number = .2;
		
		private const STACKED_COLORS:Array = [0xFF0000, 0xFFA100, 0xFFFFFF00, 0x91BF00, 0x008000];
		
		public function Demographics(_cg:ContainerGame) {
			super(_cg);
			demo = cg.game.mc_ui.mc_demographics;
			graph = demo.mc_graph;
			mf = cg.metaManager.managerMap["fur"];
			
			enableButton(demo.btn_age, "Age");
			enableButton(demo.btn_gender, "Gender");
			enableButton(demo.btn_interests, "Interests");
			
			demo.btn_close.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				cg.game.mc_ui.mc_demographics.visible = false;
			});
		}
		
		public function displayDemographic(stat_:String):void {
			if (mf == null) {
				mf = cg.metaManager.managerMap["fur"];
			}
			clearGraph();
			stat = stat_;
			graph.tf_title.text = stat;
			var axes:Array = titleToAxis[stat];
			if (axes != null) {
				graph.tf_axisx.text = axes[0];
				graph.tf_axisy.text = axes[1];
			} else {
				graph.tf_axisx.text = "Interest";
				graph.tf_axisy.text = "Furs";
			}
			
			var demo:Array = mf.getDemographics(stat);
			switch (stat) {
				case "Age":
					manualBucketGraph(demo[0],
									  [12, 18, 21, 24, 27, 30, 40, 50]);
					break;
				case "Gender":
					drawBarGraph(demo[0], demo[1]);
					break;
				case "Interests":
					drawStackedBarGraph(demo[0], demo[1]);
					break;
				// these shouldn't really be used other than for testing
				case "Money":
					//bucketGraph(demo[0], 5);
					manualBucketGraph(demo[0],
									  [0, 1, 10, 20, 50, 100, 250]);
					break;
			}
		}
		
		/**
		 * Attach listeners to show the selected demographic
		 * @param	mc
		 */
		private function enableButton(btn:DisplayObject, demographic:String):void {
			btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				displayDemographic(demographic);
			});
		}
		
		/**
		 * Bucket the given (numeric) data into buckets.
		 * @param	data		The data to visualize
		 * @param	buckets		The number of buckets to use (might end up being slightly higher)
		 */
		private function bucketGraph(data:Array, buckets:int = 4):void {
			data = data.sort();
			const DATA_MIN:Number = data[0];
			const DATA_MAX:Number = data[data.length - 1];
			const DATA_RANGE:Number = DATA_MAX - DATA_MIN;
			buckets = Math.min(DATA_RANGE, buckets - 1);
			const BUCKET_SIZE:Number = (DATA_RANGE) / buckets;
			var dataCount:Array = new Array(buckets);
			var i:int;
			for (i = 0; i < buckets; i++) {
				dataCount[i] = 0;
			}
			for each (var d:Number in data) {
				var index:int = int((d - DATA_MIN) / BUCKET_SIZE);
				// account for weirdness if bucket size isn't an integer
				if (!dataCount[index]) {
					dataCount[index] = 1;
				} else {
					dataCount[index]++;
				}
			}
			// collect metadata
			var Y_MAX:int = 0;
			var xLabels:Array = [];
			for (i = 0; i < dataCount.length; i++) {
				Y_MAX = Math.max(Y_MAX, dataCount[i]);
				xLabels.push(int(DATA_MIN + BUCKET_SIZE * (i)).toString() + '-' +
							 int(DATA_MIN + BUCKET_SIZE + (i) * BUCKET_SIZE - 1).toString());
			}
			drawBarGraph(dataCount, xLabels, Y_MAX);
		}
		
		/**
		 * Bucket the given (numeric) data into already-defined buckets and graphs it.
		 * @param	data		The data to visualize
		 * @param	buckets		The buckets to use (an array of values such as [0, 4, 5, 10] giving [0, 4), [4, 5), [5, 10])
		 * @param	xLabels		The labels to use on the x-axis (an array of Strings), null to auto-generate
		 */
		private function manualBucketGraph(data:Array, buckets:Array, xLabels:Array = null):void {
			data = data.sort();
			const DATA_MIN:Number = data[0];
			const DATA_MAX:Number = data[data.length - 1];
			const DATA_RANGE:Number = DATA_MAX - DATA_MIN;
			var dataCount:Array = bucketData(data, buckets);
			// collect metadata
			var Y_MAX:int = 0;
			var generateLabels:Boolean = xLabels == null;
			if (generateLabels) {
				xLabels = [];
			}
			for (var i:int = 0; i < dataCount.length; i++) {
				Y_MAX = Math.max(Y_MAX, dataCount[i]);
				if (generateLabels) {
					xLabels.push(int(buckets[i]).toString() + '-' + int(buckets[i + 1] - (i == dataCount.length - 1 ? 0 : 1)).toString());
				}
			}
			drawBarGraph(dataCount, xLabels, Y_MAX);
		}
		
		/**
		 * Bucket the given (numeric) data into already-defined buckets.
		 * @param	data		The data to bucket
		 * @param	buckets		The buckets to use (an array of values such as [0, 4, 5, 10] giving [0, 4), [4, 5), [5, 10])
		 * @return				Bucketed data
		 */
		public static function bucketData(data:Array, buckets:Array):Array {
			var dataCount:Array = new Array(buckets.length - 1);
			var i:int;
			for (i = 0; i < dataCount.length; i++) {
				dataCount[i] = 0;
			}
			for each (var d:Number in data) {
				var found:Boolean = false;
				for (var j:int = 1; j < dataCount.length; j++) {
					// just iterate; buckets will never be larger than ~10 anyway
					if (d < buckets[j]) {
						dataCount[j - 1]++;
						found = true;
						break;
					}
				}
				if (!found) {
					dataCount[dataCount.length - 1]++;
				}
			}
			return dataCount;
		}
		
		/**
		 * Draw a bar graph with each bar having segments
		 * @param	dataArr		2D array with 2nd dimension % distribution
		 * @param	xLabels
		 */
		private function drawStackedBarGraph(dataArr:Array, xLabels:Array):void {
			const TOTAL_BAR_WIDTH:Number = MAX_SIZES.x * (1 - BUFFER_PROPORTION);
			const BAR_WIDTH:Number = TOTAL_BAR_WIDTH / dataArr.length;
			const SPACING:Number = BAR_WIDTH * (1 + BUFFER_PROPORTION);
			var xLoc:Number = ANCHOR.x + SPACING - BAR_WIDTH;
			var i:int;
			var colInd:int;
			// graph it
			for (i = 0; i < dataArr.length; i++) {
				colInd = 0;
				// draw the bars
				var innerData:Array = dataToProportion(dataArr[i]);
				var yLoc:Number = ANCHOR.y;
				for (var j:int = 0; j < innerData.length; j++) {
					var h:Number = MAX_SIZES.y * innerData[j];
					if (isNaN(h)) h = 0;
					graph.graphics.beginFill(STACKED_COLORS[colInd], 1);
					graph.graphics.drawRect(xLoc, yLoc - h, BAR_WIDTH, h);
					graph.graphics.endFill();
					colInd = (colInd + 1) % STACKED_COLORS.length;
					yLoc -= h;
				}
				// generate the x label
				var xLbl:MovieClip = new SWC_ChartLabel();
				xLbl.tf_label.text = xLabels[i];
				xLbl.x = xLoc + BAR_WIDTH * .5;
				xLbl.y = ANCHOR.y;
				graph.addChild(xLbl);
				labels.push(xLbl);
				// move to the next spot
				xLoc += SPACING;
			}
			// generate the y labels from the bottom up
			const NUM_Y_LABELS:int = 5;
			for (i = 0; i < NUM_Y_LABELS; i++) {
				var yLbl:MovieClip = new SWC_ChartLabel();
				var pct:Number = i / (NUM_Y_LABELS - 1);
				yLbl.gotoAndStop(2);
				yLbl.tf_label.text = int(pct * 100).toString() + "%";
				yLbl.x = ANCHOR.x - 5;
				yLbl.y = ANCHOR.y - MAX_SIZES.y * pct;
				graph.addChild(yLbl);
				labels.push(yLbl);
			}
		}

		/**
		 * Draw the bar graph (assumes graphics were already cleared).
		 * @param	dataArr		data values
		 * @param	xLabels		x-axis labels, must be same length as dataArr
		 * @param	Y_MAX		largest value in dataArr (null to recompute)
		 */
		private function drawBarGraph(dataArr:Array, xLabels:Array, Y_MAX:Number = -1):void {
			if (Y_MAX == -1) {
				Y_MAX = 0;
				for each (var n:Number in dataArr) {
					Y_MAX = Math.max(Y_MAX, n);
				}
			}
			graph.graphics.beginFill(0xFF0000, 1);
			const TOTAL_BAR_WIDTH:Number = MAX_SIZES.x * (1 - BUFFER_PROPORTION);
			const BAR_WIDTH:Number = TOTAL_BAR_WIDTH / dataArr.length;
			const SPACING:Number = BAR_WIDTH * (1 + BUFFER_PROPORTION);
			var xLoc:Number = ANCHOR.x + SPACING - BAR_WIDTH;
			var i:int;
			// graph it
			for (i = 0; i < dataArr.length; i++) {
				// draw the bar
				var h:Number = MAX_SIZES.y * (dataArr[i] / Y_MAX);
				if (isNaN(h)) h = 0;
				graph.graphics.drawRect(xLoc, ANCHOR.y - h, BAR_WIDTH, h);
				// generate the x label
				var xLbl:MovieClip = new SWC_ChartLabel();
				xLbl.tf_label.text = xLabels[i];
				xLbl.x = xLoc + BAR_WIDTH * .5;
				xLbl.y = ANCHOR.y;
				graph.addChild(xLbl);
				labels.push(xLbl);
				// move to the next spot
				xLoc += SPACING;
			}
			// generate the y labels from the bottom up
			const NUM_Y_LABELS:int = Math.min(Y_MAX + 1, 7);
			for (i = 0; i < NUM_Y_LABELS; i++) {
				var yLbl:MovieClip = new SWC_ChartLabel();
				var pct:Number = (i / (NUM_Y_LABELS - 1));
				yLbl.gotoAndStop(2);
				// get a whole number, then recalculate the pct
				var trueValue:int = int(Math.round(Y_MAX * pct));
				pct = Number(trueValue) / Y_MAX;
				yLbl.tf_label.text = trueValue.toString();
				yLbl.x = ANCHOR.x - 5;
				yLbl.y = ANCHOR.y - MAX_SIZES.y * pct;
				graph.addChild(yLbl);
				labels.push(yLbl);
			}
			graph.graphics.endFill();
		}
		
		/**
		 * Modifies dataArr such that each value is changed to what % of the total value it was.
		 * @param	dataArr
		 * @return
		 */
		public static function dataToProportion(dataArr:Array):Array {
			var i:int;
			var sum:Number = 0;
			for (i = 0; i < dataArr.length; i++) {
				sum += dataArr[i];
			}
			for (i = 0; i < dataArr.length; i++) {
				dataArr[i] /= sum;
			}
			return dataArr;
		}
		
		/**
		 * Clear the graph of labels and bars.
		 */
		public function clearGraph():void {
			graph.tf_title.text = "";
			graph.tf_axisx.text = "";
			graph.tf_axisy.text = "";
			graph.graphics.clear();
			for each (var mc:MovieClip in labels) {
				if (graph.contains(mc)) {
					graph.removeChild(mc);
				}
				mc = null;
			}
			labels = [];
		}
	}
}