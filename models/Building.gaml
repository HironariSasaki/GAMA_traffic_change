/**
* Name: Building
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Building

import 'Main.gaml'

species building {
	
	int blcode;
	int maxhigh;
	string type;
	int build_id;
	rgb color<-#grey;
	rgb residence_color <- #black;
	int human_num<-0;
	float height;
	string building_name;
	
	aspect base {
		
		//draw shape color:color depth:human_num;
		if type = 'shop' {
			draw shape color:color depth:human_num border:true;
		}else {
			draw shape color:color depth:human_num;
		}
		

	}
}

