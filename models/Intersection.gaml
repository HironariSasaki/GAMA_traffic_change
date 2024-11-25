/**
* Name: Intersection
* Based on the internal empty template. 
* Author: HironariSasaki
* Tags: 
*/


model Intersection

import 'Main.gaml'

species intersection skills:[intersection_skill] parallel:true{
	
	bool is_traffic_signal; //信号フラグ
	string signal_type; //信号機種別
	list<road> v_roads_in; //仮想のroad_in
	int inter_num; //地図データのノード番号連携用
	bool not_node;
	int node_id;
	string text_node_id;
	list<point> signal_locations;
	rgb node_color<-#black;
	int node_size<-1;
	//list<intersection> delete_node <- [];
	
	int signal_counter; //源氏切り替えのためのカウンター
	int signal_cycle <- 60; //青から赤の順に切り替わるその一巡する時間(ステップ数が１サイクルなので６０)
	float signal_split <- 0.5; //signal_sycleの時間のうち、１方向に割り当てられる信号時間の配分
	int phase_time <- int(signal_cycle * signal_split); //信号機の時間間隔
	bool is_blue <- true; //1方向が青であるか判定
	list<road> current_shows1;
	list<road> current_shows2;
	
	init {
		//信号機であるかどうか判別
		if (signal_type != nil and signal_type != "1") {
			is_traffic_signal <- true;
		}
	}
	
	//信号の切り替え
	reflex control_signal when: signal_counter >= phase_time and is_traffic_signal {
//		write road(roads_in[0]);
		signal_counter <- 0;
		if (length(roads_in) >= 4) {//三叉路の場合
//			write road(roads_in[0]);
			if (is_blue) {
				
				stop[0] <- [];
				current_shows1 <- [road(roads_in[0]), road(roads_in[2])];
				stop[0] <- current_shows1;
				phase_time <- int(signal_cycle * signal_split);
			} else {
				current_shows2 <- [road(roads_in[1]), road(roads_in[3])];
				stop[0] <- [];
				stop[0] <- current_shows2;
				phase_time <- int(signal_cycle * (1-signal_split));
			}
		} else if (length(roads_in) = 3) {//三叉路の場合
			if (is_blue) {
				stop[0] <- [];
				current_shows1 <- [road(roads_in[0])];
				stop[0] <- current_shows1;
				phase_time <- int(signal_cycle * signal_split);
			} else {
				stop[0] <- [];
				current_shows2 <- [road(roads_in[1]), road(roads_in[2])];
				stop[0] <- current_shows2;
				phase_time <- int(signal_cycle * (1-signal_split));
			}
		}
		is_blue <- !is_blue;
	}
	
	// counterをインクリメント
	reflex increment_count when: is_traffic_signal and length(roads_in) > 2{
		signal_counter <- signal_counter + 1;
	}
		point signal_loc_re (int x) {
		float dx0;
		float dy0;
		float dx1;
		float dy1;
		float a0;
		float a1;
		if (x = 0 or x = 2) {
			dx0 <- location.x - v_roads_in[0].location.x;
			dy0 <- location.y - v_roads_in[0].location.y;
			if (dx0 != 0) {
				a0 <- dy0 / dx0;
				if (x = 0) {
					return point(location.x + 3.0 #m, location.y + (3.0 #m * a0), 10 #m);
				} else if (x = 2) {
					return point(location.x - 3.0 #m, location.y - (3.0 #m * a0), 10 #m);
				}
			} else {
				if (x = 0) {
					return point(location.x, location.y + (3.0 #m), 10 #m);
				} else if (x = 2) {
					return point(location.x, location.y - (3.0 #m), 10 #m);
				}
			}
		}
		if (x = 1 or x = 3) {
			dx1 <- location.x - v_roads_in[1].location.x;
			dy1 <- location.y - v_roads_in[1].location.y;
			if (dx1 != 0) {
				a1 <- dy1 / dx1;
				if (x = 1) {
					return point(location.x - (3.0 #m), location.y - 3.0 #m * a1, 10 #m);
				} else if (x = 3) {
					return point(location.x + (3.0 #m), location.y + 3.0 #m * a1, 10 #m);
				}
			} else {
				if (x = 1) {
					return point(location.x - (3.0 #m), location.y, 10 #m);
				} else if (x = 3) {
					return point(location.x + (3.0 #m), location.y, 10 #m);
				}
			}
		}
	}
	
	aspect base {
		//draw circle(node_size) at:location color:node_color border:false; // aspectは名前を指定しているもの
		if node_id_on = true {
			draw string(node_id) color:#black;
		}
		if (is_traffic_signal) {
			if (length(v_roads_in) = 4) {
				draw sphere(2 #m) at: signal_locations[0] color: is_blue ? #green : #red;
				draw sphere(2 #m) at: signal_locations[1] color: is_blue ? #red : #green;
				draw sphere(2 #m) at: signal_locations[2] color: is_blue ? #green : #red;
				draw sphere(2 #m) at: signal_locations[3] color: is_blue ? #red : #green;
			} else if (length(v_roads_in) = 3) { //T字路の信号表示
				draw sphere(2 #m) at: signal_locations[0] color: is_blue ? #green : #red;
				draw sphere(2 #m) at: signal_locations[1] color: is_blue ? #red : #green;
				draw sphere(2 #m) at: signal_locations[2] color: is_blue ? #green : #red;
			}
		}
	}
	}

