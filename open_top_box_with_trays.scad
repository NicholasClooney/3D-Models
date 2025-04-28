// ======================
// Parameters (define tray first)
// ======================

// Tray dimensions
tray_length = 150;     // Each tray's length (X)
tray_width = 35;      // Each tray's width (Y)
tray_height = 69;     // Tray usable height (Z)

// Tray setup
tray_count = 3;       // How many trays

// Wall and divider settings
wall_thickness = 2;    // Outer wall thickness
floor_thickness = 4;   // Bottom thickness
divider_thickness = 2; // Divider thickness

// Fillet radius
box_fillet_radius = wall_thickness / 2;     // Corner rounding radius
divider_fillet_radius = divider_thickness / 2;

// ======================
// Derived dimensions
// ======================

inner_width = tray_length;
inner_length = tray_width * tray_count + (tray_count - 1) * divider_thickness;
inner_height = tray_height;

box_length = inner_length + 2 * wall_thickness;
box_width = inner_width + 2 * wall_thickness;
box_height = inner_height + floor_thickness;

tolerance = 0.001;

module debug(name, l, w, h) {
    echo(str("Your ", name, " is ", l, " by ", w, " by ", h));
}

// ======================
// Helper Modules
// ======================

module fillet(r) {
    minkowski() {
        children();  // this means "apply to whatever shape is inside"
        resize([r, r, r])
            sphere(10); // Or sphere(r) if you want a perfect sphere
    }
}

module filleted_box(size, fillet_radius) {
    resize(size)
    fillet(fillet_radius) {
        cube(size, center=true);
    }
}

module dividers() {
    for (i = [1 : tray_count - 1]) {
        // since we are centered, and it should be at n * tray_width + how many existing dividers and the half divider width to be centered...
        center = -inner_length/2 + i * tray_width + (i - 1) * divider_thickness + divider_thickness/2;
        translate([
            center,
            0,
            0
        ])
        filleted_box([divider_thickness, inner_width, inner_height], divider_fillet_radius);
    }
}

module box_walls(size, thickness) {
    difference() {
        cube(size, center=true);
        cube([size[0] - 2 * thickness, size[1] - 2 * thickness, size[2]], center=true);
    }
}

module filleted_box_walls(size, thickness, fillet_radius) {
    resize(size)
    fillet(fillet_radius) {
        box_walls(size, thickness);
    }
}

module filleted_walls() {
    filleted_box_walls([box_length, box_width, box_height], wall_thickness, box_fillet_radius);
}

module inner_bottom_plate() {
    cube([inner_length + tolerance, inner_width + tolerance, floor_thickness], center=true);
}

module open_top_box() {
    // fillet(fillet_radius)
    filleted_walls();

    translate([0, 0, -box_height/2 + floor_thickness/2])
        inner_bottom_plate();

    translate([0, 0, (box_height - inner_height)/2 + tolerance])
        dividers();
}

open_top_box();
