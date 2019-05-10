using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor;

class s56watchfaceView extends Ui.WatchFace {
		function titleColor() {
			var color = App.getApp().getProperty("TitleColor");
			switch (color) {
				case 0:
					return Gfx.COLOR_LT_GRAY;
				case 1:
					return Gfx.COLOR_GREEN;
				case 2:
					return Gfx.COLOR_RED;
				case 3:
					return Gfx.COLOR_BLUE;
				case 4:
					return Gfx.COLOR_DK_GRAY;
				case 5:
					return Gfx.COLOR_DK_GREEN;
				case 6:
					return Gfx.COLOR_DK_RED;
				case 7:
					return Gfx.COLOR_DK_BLUE;
				default:
					return Gfx.COLOR_WHITE;
			}
		}

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
			dc.fillRectangle(0,0, dc.getWidth(), dc.getHeight());
    
			drawTime(dc);
			drawDate(dc);
			drawLogo(dc);
			drawInformatios(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    function drawLogo(dc) {
		var logotype = App.getApp().getProperty("Logo");
		if (logotype == 0) {
			var width = 151;
			var height = 54;
			var x = ((dc.getWidth() / 2) - width/2);
			var y = ((dc.getHeight() / 2)  - height/2) + 5;
        		
			// If round watch height and width are the same
			if(dc.getWidth() == dc.getHeight()) {
				y += -10;
			}
			
			var logo = Ui.loadResource(Rez.Drawables.LogoA);
			dc.drawBitmap(x, y, logo);
		} else if (logotype == 1) {
			var width = 91;
			var height = 37;
			var x = ((dc.getWidth() / 2) - width/2);
			var y = ((dc.getHeight() / 2)  - height/2);
        		
			// If round watch height and width are the same
			if(dc.getWidth() == dc.getHeight()){
				y += -10;
			}
			
			var logo = Ui.loadResource(Rez.Drawables.LogoB);
			dc.drawBitmap(x, y, logo);
		}
    }
    
    function drawTime(dc) {
		// Get the current time and format it correctly
    var timeFormat = "$1$:$2$";
    var clockTime = Sys.getClockTime();
    var hours = clockTime.hour;
    if (!Sys.getDeviceSettings().is24Hour) {
		if (hours > 12) {
			hours = hours - 12;
		}
    } else {
      if (App.getApp().getProperty("UseMilitaryFormat")) {
        timeFormat = "$1$:$2$";
        hours = hours.format("%02d");
      }
    }
    var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
      
    // Draw the time
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		var x = dc.getWidth() / 2;
		var y = dc.getHeight() - (dc.getHeight() * 0.28);
	
		dc.drawText(x, y, Gfx.FONT_NUMBER_MILD, timeString, Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function drawDate(dc) {
		var dayNum = Calendar.info(Time.now(), Time.FORMAT_LONG).day + ".";
    var monthNum = Calendar.info(Time.now(), Time.FORMAT_LONG).month;
    var dateStr = Lang.format("$2$ $1$", [monthNum, dayNum]);
        
    var x = dc.getWidth() / 2;
    var y = dc.getHeight() - (dc.getHeight() * 0.15);
        
		dc.setColor(titleColor(), Gfx.COLOR_TRANSPARENT);
    dc.drawText(x, y, Gfx.FONT_SYSTEM_SMALL, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
	}
	
	function drawInformatios(dc) {
		var showSteps = App.getApp().getProperty("ShowSteps");
		var showBattery = App.getApp().getProperty("ShowBattery");
		var y = 25;
		var offset = 25;

		if (showSteps) {
			var x = (dc.getWidth() / 2);
			if (showBattery) {
				x += offset;
			}

			var info = ActivityMonitor.getInfo();
			var stepsString = null;
			
			var showStepsPercentage = App.getApp().getProperty("ShowStepsPercentage");
			if (showStepsPercentage) {
				var steps = (info.steps/info.stepGoal) * 100;
				stepsString = Lang.format("$1$%", [steps]);
			} else {
				var steps = (info.steps/1000.0).format("%.1f");
				stepsString = Lang.format("$1$k", [steps]);
			}
			
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			dc.drawText(x, y, Gfx.FONT_SYSTEM_XTINY, stepsString, Gfx.TEXT_JUSTIFY_CENTER);
			dc.setColor(titleColor(), Gfx.COLOR_TRANSPARENT);
			dc.drawText(x, y - 15, Gfx.FONT_SYSTEM_XTINY, "steps", Gfx.TEXT_JUSTIFY_CENTER);
		}

		if (showBattery) {
			var x = (dc.getWidth() / 2);
			if (showSteps) {
				x -= offset;
			}

			var battery = Sys.getSystemStats().battery;
			var batteryString = Lang.format("$1$%", [battery.format("%d")]);
			var showBatteryColor = App.getApp().getProperty("ShowBattery");

			var color = Gfx.COLOR_WHITE;
			if (showBatteryColor) {
				if (battery <= 100 && battery >= 50) {
					color = Gfx.COLOR_WHITE;
				} else if (battery < 50 && battery >= 35) {
					color = Gfx.COLOR_YELLOW;
				} else if (battery < 35 && battery >= 10) {
					color = Gfx.COLOR_ORANGE;
				} else if (battery < 10) {
					color = Gfx.COLOR_RED;
				}
			}

			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			dc.drawText(x, y, Gfx.FONT_SYSTEM_XTINY, batteryString, Gfx.TEXT_JUSTIFY_CENTER);
			dc.setColor(titleColor(), Gfx.COLOR_TRANSPARENT);
			dc.drawText(x, y - 15, Gfx.FONT_SYSTEM_XTINY, "battery", Gfx.TEXT_JUSTIFY_CENTER);
		}
	}
}
