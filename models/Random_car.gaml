/**
* Name: Randomcar
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Randomcar

import 'Main.gaml'
import 'Vehicle.gaml'

species random_car parent:vehicle{
	
	init {
		vehicle_length <- 3.4;
		max_speed <- 60 #km/#h;
		max_acceleration <- 3.5;
		ignore_oneway <- true;
	}
	
	reflex {
		if current_road != nil {
			max_speed <- road(current_road).maxspeed;
		}
		do drive_random(road_network);
	}
	
	aspect base {
		draw circle(3) color:#yellow border:true;
	}
	
}

