// include instead of use, so we get the pitch
include <gridfinity_modules.scad>

// X tiles (u)
xsize = 5.0; // .1
// Y tiles (u)
ysize = 3.0; // .1

// Left Padding (mm)
lpadding = 0; // .1
// Right Padding (mm)
rpadding = 0; // .1
// Top Padding (mm)
tpadding = 0; // .1
// Bottom Padding (mm)
bpadding = 0; // .1

weighted = false;
lid = false;

if (lid) {
  base_lid(xsize, ysize);
}
else if (weighted) {
  weighted_baseplate(xsize, ysize);
}
else {
  frame_plain(xsize, ysize);
}


module base_lid(num_x, num_y) {
  magnet_od = 6.5;
  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_od/2);
  magnet_thickness = 2.4;
  eps = 0.1;
  
  translate([0, 0, 7]) frame_plain(xsize, ysize, trim=0.25);
  difference() {
    grid_block(xsize, ysize, 1, magnet_diameter=0, screw_depth=0);
    gridcopy(num_x, num_y) {
      cornercopy(magnet_position) {
        translate([0, 0, 7-magnet_thickness])
        cylinder(d=magnet_od, h=magnet_thickness+eps, $fn=48);
      }
    }
  }
}


module weighted_baseplate(num_x, num_y) {
  magnet_od = 6.5;
  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_od/2);
  magnet_thickness = 2.4;
  eps = 0.1;
  
  difference() {
    frame_plain(num_x, num_y, 6.4);
    
    gridcopy(num_x, num_y) {
      cornercopy(magnet_position) {
        translate([0, 0, -magnet_thickness])
        cylinder(d=magnet_od, h=magnet_thickness+eps, $fn=48);
        
        translate([0, 0, -6.4]) cylinder(d=3.5, h=6.4, $fn=24);
        
        // counter-sunk holes in the bottom
        translate([0, 0, -6.41]) cylinder(d1=8.5, d2=3.5, h=2.5, $fn=24);
      }
      
      translate([-10.7, -10.7, -6.41]) cube([21.4, 21.4, 4.01]);
      
      for (a2=[0,90]) rotate([0, 0, a2])
      hull() for (a=[0, 180]) rotate([0, 0, a])
      translate([-14.9519, 0, -6.41]) cylinder(d=8.5, h=2.01, $fn=24);
    }
  }
}


module frame_plain(num_x, num_y, extra_down=0, trim=0) {
  ht = extra_down > 0 ? 4.4 : 5;
  corner_radius = 3.75;
  corner_position = gridfinity_pitch/2-corner_radius-trim;

  whole_num_x = floor(num_x);
  frac_num_x = num_x % 1;
  x_frac = frac_num_x != 0;

  whole_num_y = floor(num_y);
  frac_num_y = num_y % 1;
  y_frac = frac_num_y != 0;

  difference() {
    hull() cornercopypadded(corner_position + lpadding, corner_position + rpadding, corner_position + tpadding, corner_position + bpadding, num_x, num_y) 
    translate([0, 0, -extra_down]) cylinder(r=corner_radius, h=ht+extra_down, $fn=44);
    translate([0, 0, trim ? 0 : -0.01])
    union() {
      render() gridcopy(num_x, num_y) pad_oversize(margins=1);
      if (x_frac) render() translate([whole_num_x * gridfinity_pitch, 0, 0]) gridcopy(1, whole_num_y) pad_oversize(margins=1, frac_num_x, 1);
      if (y_frac) render() translate([0, whole_num_y * gridfinity_pitch, 0]) gridcopy(whole_num_x, 1) pad_oversize(margins=1, 1, frac_num_y);
      if (x_frac && y_frac) render() translate([whole_num_x * gridfinity_pitch, whole_num_y * gridfinity_pitch, 0]) pad_oversize(margins=1, frac_num_x, frac_num_y);
    }
  }
}