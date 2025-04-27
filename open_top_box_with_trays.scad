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
fillet_radius = 2;     // Corner rounding radius

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

// Fillet a box, adjusting for size shrinkage automatically
module fillet_box(l, w, h, r) {
    fillet(r) {
        cube([l - 2 * r, w - 2 * r, h - 2 * r], center=true);
    }
}

module fillet(r) {
    minkowski() {
        children();  // this means "apply to whatever shape is inside"
        resize([r, r, r])
            sphere(10); // Or sphere(r) if you want a perfect sphere
    }
}

module box_body() {
    debug("box body", box_length, box_width, box_height);
    cube([box_length, box_width, box_height], center=true);
}

module inner_space() {
    debug("inner space", inner_length, inner_width, inner_height);
    cube([inner_length, inner_width, inner_height], center=true);
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
        cube([divider_thickness, inner_width, inner_height], center=true);
    }
}

module open_top_box() {
    difference() {
        box_body();
        translate([0, 0, (box_height - inner_height)/2 + tolerance])
            inner_space();
    }

    translate([0, 0, (box_height - inner_height)/2 + tolerance])
        dividers();
}

open_top_box();
