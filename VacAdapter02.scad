// Brian Palmer 2019
// ver 0.1 in the begining
// ver 0.2 fixed bend radious bug
// ver 0.3 changed vars prefix to green and yellow
// ver 0.4 changed tapering so it's spread equally across the length of the sleeve so that the user specified diam. is placed in the center of the sleeve.
// ver 1.0 added options to set middle diam. end diam.
// Tube bending part derived from https://charuchopra84blog.wordpress.com/2014/06/30/making-bend-pipes-in-openscad/
/* [Vacuum Adapter ] */
// quality
$fn=128;


wallThickness=3;

/* [Green End] */
greenDiameterType="ID"; // [ID: ID - making a female end,OD: OD - making a male end]
greenDiameter=42.5;
greenSleeveLength= 40; // mm
greenTaper=2; // mm
/* [ middle ] */
middleDiameterType="GR"; // [ID:ID, OD:OD, GR: make it like the green end, YL: make it like the yellow end]
middleDiameter=42.5; // mm
middleBendAngle=75; // [0:No bend, 5:5 deg., 10:10 deg., 15:15 deg., 20:20 deg., 22.5: 22.5 deg. (make an octagonal tube frame!), 25:25 deg., 30:30 deg., 35:35 deg., 45:45 deg., 50:50 deg., 55:55 deg., 60:60 deg., 65:65 deg., 70:70 deg., 75:75 deg., 80:80 deg., 85:85 deg., 90:90 deg.]
middleBendRadius=6.35; // [4.0:4 in., 3.5:3 1.2 in., 3.0:3 in., 2.5:2 1/2 in.,2.0:2 in.,1.5:1 1/2 in.,1:1 in., .5:1/2 in., .25:1/4 in., .125: 1/8 in., 0: none]
/* [Yellow End] */
yellowDiameterType="ID"; // [ID: ID - making a female end,OD: OD - making a male end]
yellowDiameter=42; // mm
yellowSleeveLength=35; // mm
yellowTaper=2; // mm

/* [hidden] */
mba=middleBendAngle;
mbr=middleBendRadius;
wt=wallThickness;

// prepare green side vars
udt=greenDiameterType;
ud=greenDiameterType == "OD" ? greenDiameter: (greenDiameter)+(wt*2);
udi=ud-(wt*2); // inner wall
usl=greenSleeveLength;
ut=greenDiameterType == "OD" ? (greenTaper) * -1:greenTaper;

// prepare yellow side vars
ldt=yellowDiameterType;
ld=yellowDiameterType == "OD" ? yellowDiameter: (yellowDiameter)+(wt*2) ;
ldi=ld-(wt*2); // inner wall
lsl=yellowSleeveLength;
lt=yellowDiameterType == "OD" ? (yellowTaper) * -1: yellowTaper;
// prepare middle side vars
mdt=middleDiameterType;
md=middleDiameterType == "OD" ? middleDiameter: middleDiameterType == "ID" ? (middleDiameter)+(wt*2) : middleDiameterType == "GR" ? ud-(ut/2): ld-(lt/2);
echo(ud);
echo(md);
echo(ld);

mdi=md-(wt*2); // inner wall
mr=md/2; // middle radius
// length of adapter arms. 0 if not needed.
yellowArmLen=abs(((ld+(lt/2))-md)*1.5);
greenArmlen=abs(((ud+(ut/2))-md)*1.5);


union() {

// yellow sleeve 
color("Khaki",1) {  
    translate([mbr+mr, -yellowArmLen, 0])
    rotate([90, 0, 0])
    tube(ld-(lt/2), ld+(lt/2), ldi-(lt/2), ldi+(lt/2), lsl);
}

// yellow adapter  
color("Khaki",1) {      
    translate([mbr+mr, 0.00, 0])
    rotate([90, 0, 0])
    tube(md, ld-(lt/2), mdi, ldi-(lt/2),yellowArmLen);
}

// middle bend
difference()
{
    difference()
    {    
        // torus
        rotate_extrude(angle=mba)
        translate([mbr + mr, 0, 0])
        circle(d=md);
        
        // torus cutout
        rotate_extrude(angle=mba+1)
        translate([mbr + mr, 0, 0])
        circle(d=mdi);
    }
     
    union()
    {
        // yellow cutout
        translate([-(1000-(mbr + md + (md/2))) * (((mba) <= 180)?1:0), -1000, -500])
        cube([1000, 1000, 1000]);

        // green cutout
        rotate([0, 0, mba])
        translate([-(1000-(mbr + md + (md/2))) * (((mba) <= 180)?1:0), 0, -500])
        cube([1000, 1000, 1000]);
    }
}


// green adapter 
color("DarkSeaGreen",1) {
    rotate([0, 0, mba])
    translate([mbr + mr, -0.0, 0])
    rotate([-90, 0, 0])
    tube(md, ud-(ut/2), mdi, udi-(ut/2), greenArmlen);
}


// green sleeve
color("DarkSeaGreen",1) {
    rotate([0, 0, mba])
    translate([mbr + mr, greenArmlen, 0])
    rotate([-90, 0, 0])
    tube(ud-(ut/2), ud+(ut/2), udi-(ut/2), udi+(ut/2), usl);
}

}

module tube(ODd1,ODd2, IDd1, IDd2, tLen)
{
    //render()
    {
    difference() {
        cylinder(d1=ODd1, d2=ODd2, h=tLen);
        translate([0,0,-2]){
            cylinder(d1=IDd1,d2=IDd2, h=tLen+10);
        }
    }
}
}
