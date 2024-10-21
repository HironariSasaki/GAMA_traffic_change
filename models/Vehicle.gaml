/**
* Name: Vehicle
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Vehicle

import 'Main.gaml'


species vehicle skills:[driving] {  
	point loc; //車の位置を表す
	bool drive_ov<-true; //再走行を許可する
	
	//車の位置を計算
	point calc_loc {
		//車線ごとに車の位置をずらす
		float val <- (road(current_road).num_lanes - current_lane) + 0.5; //current_roadはdrivingスキルに設定されている関数
		val <- on_linked_road ? val * - 1:val;
		if (val = 0) {
			return location;
		} else {
			return (location - {cos(heading + 90) * val, sin(heading + 90) * val}); //headingは向いてる方向、車線ごとに位置の計算
		}
	}
}


