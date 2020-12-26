
/*//////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -
              -   http://heartygfx.blogspot.com    -
              -       OpenScad Parametric Box      -
              -         CC BY-NC 3.0 License       -
////////////////////////////////////////////////////////////////////
12/02/2016 - Fixed minor bug
28/02/2016 - Added holes ventilation option
09/03/2016 - Added PCB feet support, fixed the shell artefact on export mode.

*/////////////////////////// - Info - //////////////////////////////

// All coordinates are starting as integrated circuit pins.
// From the top view :

//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB


////////////////////////////////////////////////////////////////////


////////// - Paramètres de la boite - Box parameters - /////////////

/* [Box dimensions] */
// - Longueur - Length
Length        = 80;
// - Largeur - Width
Width         = 61;
// - Hauteur - Height
Height        = 22;
// - Epaisseur - Wall thickness
Thick         = 2;//[2:5]

/* [Box options] */
// - Diamètre Coin arrondi - Filet diameter
Filet         = 2;//[0.1:12]
// - lissage de l'arrondi - Filet smoothness
Resolution    = 50;//[1:100]
// - Tolérance - Tolerance (Panel/rails gap)
m             = 0.9;
// Pieds PCB - PCB feet (x4)
PCBFeet       = true; 
// - Decorations to ventilation holes
Vent          = true;
// - Decoration-Holes width (in mm)
Vent_width    = 1.5;

/*[PCB Test Modes]*/
PCB1_TestFit=true;

/* [PCB_Feet] */
//All dimensions are from the center foot axis

// - Coin bas gauche - Low left corner X position
PCB1PosX         = 2;
// - Coin bas gauche - Low left corner Y position
PCB1PosY         = 2;
// - Longueur PCB - PCB Length
PCB1Length       = 50;
// - Largeur PCB - PCB Width
PCB1Width        = 34;
// - Heuteur pied - Feet height
PCB1FootHeight      = 6;
// - Diamètre pied - Foot diameter
PCB1FootDia         = 6;
// - Diamètre trou - Hole diameter
PCB1FootHole        = 2.9;

// - Coin bas gauche - Low left corner X position
PCB2PosX         = 11;
// - Coin bas gauche - Low left corner Y position
PCB2PosY         = PCB1Width + 22;
// - Longueur PCB - PCB Length
PCB2Length       = 44.2;
// - Largeur PCB - PCB Width
PCB2Width        = 21;
// - Heuteur pied - Feet height
PCB2FootHeight      = 10;
// - Diamètre pied - Foot diameter
PCB2FootDia         = 6;
// - Diamètre trou - Hole diameter
PCB2FootHole        = 3;


/* [STL element to export] */
//Coque haut - Top shell
TShell          = false;// [0:No, 1:Yes]
//Coque bas- Bottom shell
BShell          = true;// [0:No, 1:Yes]
//Panneau avant - Front panel
FPanL           = false;// [0:No, 1:Yes]
//Panneau arrière - Back panel
BPanL           = false;// [0:No, 1:Yes]



/* [Hidden] */
// - Couleur coque - Shell color
Couleur1        = "Orange";
// - Couleur panneaux - Panels color
Couleur2        = "OrangeRed";
// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick       = Vent ? Thick*2 : Thick;
// - Depth decoration
Dec_size        = Vent ? Thick*2 : 0.8;


/////////// - Generic rounded box - //////////

module RoundBox($a=Length, $b=Width, $c=Height){// Cube bords arrondis
    $fn=Resolution;
    translate([0,Filet,Filet]){
        minkowski (){
            cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
            rotate([0,90,0]){
                cylinder(r=Filet,h=Length/2, center = false);
            }
        }
    }
}// End of RoundBox Module


////////////////////////////////// - Module Coque/Shell - //////////////////////////////////

module Coque(){//Coque - Shell
    Thick = Thick*2;
    difference(){
        difference(){//sides decoration
            union(){
                difference() {//soustraction de la forme centrale - Substraction Fileted box
                    difference(){//soustraction cube median - Median cube slicer
                        union() {//union
                            difference(){//Coque
                                RoundBox();
                                translate([Thick/2,Thick/2,Thick/2]){
                                    RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                                }
                            }//Fin diff Coque
                            
                            difference(){//largeur Rails
                                translate([Thick+m,Thick/2,Thick/2]){// Rails
                                    RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2));
                                }//fin Rails
                                translate([((Thick+m/2)*1.55),Thick/2,Thick/2+0.1]){ // +0.1 added to avoid the artefact
                                    RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick);
                                }
                            }//Fin largeur Rails
                        }//Fin union
                        
                        translate([-Thick,-Thick,Height/2]){// Cube à soustraire
                            cube ([Length+100, Width+100, Height], center=false);
                        }
                    }//fin soustraction cube median - End Median cube slicer
                    translate([-Thick/2,Thick,Thick]){// Forme de soustraction centrale
                        RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);
                    }
                }

                difference(){// wall fixation box legs
                    union(){
                        translate([3*Thick +5,Thick,Height/2]){
                            rotate([90,0,0]){
                                $fn=6;
                                cylinder(d=16,Thick/2);
                            }
                        }

                        translate([Length-((3*Thick)+5),Thick,Height/2]){
                            rotate([90,0,0]){
                                $fn=6;
                                cylinder(d=16,Thick/2);
                            }
                        }
                    }
                    translate([4,Thick+Filet,Height/2-57]){
                        rotate([45,0,0]){
                            cube([Length,40,40]);
                        }
                    }
                    translate([0,-(Thick*1.46),Height/2]){
                        cube([Length,Thick*2,10]);
                    }
                } //Fin fixation box legs
            }

            union(){// outbox sides decorations
                for(i=[0:Thick:Length/4]){
                    translate([10+i,-Dec_Thick+Dec_size,1]){
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,-Dec_Thick+Dec_size,1]){
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,Width-Dec_size,1]){
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([10+i,Width-Dec_size,1]){
                        cube([Vent_width,Dec_Thick,Height/4]);
                    }
                }// fin de for
            }//fin union decoration
        }//fin difference decoration


        union(){ //sides holes
            $fn=50;
            translate([3*Thick+5,20,Height/2+4]){
                rotate([90,0,0]){
                    cylinder(d=2,20);
                }
            }
            translate([Length-((3*Thick)+5),20,Height/2+4]){
                rotate([90,0,0]){
                    cylinder(d=2,20);
                }
            }
            translate([3*Thick+5,Width+5,Height/2-4]){
                rotate([90,0,0]){
                    cylinder(d=2,20);
                }
            }
            translate([Length-((3*Thick)+5),Width+5,Height/2-4]){
                rotate([90,0,0]){
                    cylinder(d=2,20);
                }
            }
        }//fin de sides holes
    }//fin de difference holes
}// fin coque

/////////////////////// - Foot with base filet - /////////////////////////////
module foot(FootDia,FootHole,FootHeight){
    Filet=2;
    color(Couleur1){
        translate([0,0,Filet-1.5]){
            difference(){
                difference(){
                    cylinder(d=FootDia+Filet,FootHeight-Thick, $fn=100);
                    rotate_extrude($fn=100){
                        translate([(FootDia+Filet*2)/2,Filet,0]){
                            minkowski(){
                                square(10);
                                circle(Filet, $fn=100);
                            }
                        }
                    }
                }
                cylinder(d=FootHole,FootHeight+1, $fn=100);
            }
        }
    }
}// Fin module foot

module Feet(FootHeight, FootDia, FootHole, PCBLength, PCBWidth, PCBName, Foot1_X, Foot1_Y,Foot2_X, Foot2_Y,Foot3_X, Foot3_Y,Foot4_X, Foot4_Y,){
    
    // Holds the absolute reference values for the "left", "bottom" and "base" edges
    PCB_LeftEdgeX = 3*Thick+2;
    PCB_BottomEdgeY = Thick+5;
    PCB_BaseEdgeZ = FootHeight+(Thick/2)-0.5;
    PCB_RightEdgeX = PCB_LeftEdgeX + PCBLength;
    PCB_TopEdgeY = PCB_BottomEdgeY + PCBWidth;
    
    //////////////////// - PCB only visible in the preview mode - /////////////////////
    translate([PCB_LeftEdgeX,PCB_BottomEdgeY,PCB_BaseEdgeZ]){
        %square ([PCBLength,PCBWidth]);
        translate([PCBLength/2,PCBWidth/2,0.5]){
            color("Olive"){
                %text(PCBName, halign="center", valign="center", font="Arial black");
            }
        }
    }

    translate([PCB_LeftEdgeX, PCB_BottomEdgeY, PCB_BaseEdgeZ]){
        %cube([10,10,2]);
        translate([5,5,2]){
            color("Olive"){
                %text("1", halign="center", valign="center", font="Arial black", size=3);
            }
        }
    }
    translate([PCB_LeftEdgeX, PCB_TopEdgeY-10, PCB_BaseEdgeZ]){
        %cube([10,10,2]);
        translate([5,5,2]){
            color("Olive"){
                %text("2", halign="center", valign="center", font="Arial black", size=3);
            }
        }
    }
    translate([PCB_RightEdgeX-10, PCB_BottomEdgeY, PCB_BaseEdgeZ]){
        %cube([10,10,2]);
        translate([5,5,2]){
            color("Olive"){
                %text("3", halign="center", valign="center", font="Arial black", size=3);
            }
        }
    }
    translate([PCB_RightEdgeX-10, PCB_TopEdgeY-10, PCB_BaseEdgeZ]){
        %cube([10,10,2]);
        translate([5,5,2]){
            color("Olive"){
                %text("4", halign="center", valign="center", font="Arial black", size=3);
            }
        }
    }
    Foot1_X=12;
    Foot1_Y=5;
    Foot2_X=12;
    Foot2_Y=21.5;
    Foot3_X=7.23;
    Foot3_Y=1.6;
    Foot4_X=19;
    Foot4_Y=18;
    
    Foot1_Offset_LeftEdge=PCB_LeftEdgeX+Foot1_X;
    Foot1_Offset_BottomEdge=PCB_BottomEdgeY+Foot1_Y;
    Foot2_Offset_LeftEdge=PCB_LeftEdgeX+Foot2_X;
    Foot2_Offset_TopEdge=PCB_TopEdgeY-Foot2_Y;
    Foot3_Offset_RightEdge=PCB_RightEdgeX-Foot3_X;
    Foot3_Offset_BottomEdge=PCB_BottomEdgeY+Foot3_Y;    
    Foot4_Offset_RightEdge=PCB_RightEdgeX-Foot4_X;
    Foot4_Offset_TopEdge=PCB_TopEdgeY-Foot4_Y;

    ////////////////////////////// - 4 Feet - //////////////////////////////////////////
    translate([Foot1_Offset_LeftEdge, Foot1_Offset_BottomEdge, Thick/2]){
        foot(FootDia,FootHole,FootHeight);
    }
    
    translate([Foot2_Offset_LeftEdge, Foot2_Offset_TopEdge, Thick/2]){
        foot(FootDia,FootHole,FootHeight);
    }

    translate([Foot3_Offset_RightEdge, Foot3_Offset_BottomEdge, Thick/2]){
        foot(FootDia,FootHole,FootHeight);
    }
    
    translate([Foot4_Offset_RightEdge, Foot4_Offset_TopEdge, Thick/2]){
        foot(FootDia,FootHole,FootHeight);
    }
    
} // Fin du module Feet

////////////////////////////////////////////////////////////////////////
////////////////////// <- Holes Panel Manager -> ///////////////////////
////////////////////////////////////////////////////////////////////////

//                           <- Panel ->
module Panel(Length,Width,Thick,Filet){
    scale([0.5,1,1]) {
        minkowski(){
            cube([Thick,Width-(Thick*2+Filet*2+m),Height-(Thick*2+Filet*2+m)]);
            translate([0,Filet,Filet]) {
                rotate([0,90,0]) {
                    cylinder(r=Filet,h=Thick, $fn=100);
                }
            }
        }
    }
}

//                          <- Circle hole ->
// Cx=Cylinder X position | Cy=Cylinder Y position | Cdia= Cylinder dia | Cheight=Cyl height
module CylinderHole(OnOff,Cx,Cy,Cdia){
    if(OnOff==1) {
        translate([Cx,Cy,-1]) {
            cylinder(d=Cdia,10, $fn=50);
        }
    }
}
//                          <- Square hole ->
// Sx=Square X position | Sy=Square Y position | Sl= Square Length | Sw=Square Width | Filet = Round corner
module SquareHole(OnOff,Sx,Sy,Sl,Sw,Filet){
    if(OnOff==1) {
        minkowski(){
            translate([Sx+Filet/2,Sy+Filet/2,-1]) {
                cube([Sl-Filet,Sw-Filet,10]);
                cylinder(d=Filet,h=10, $fn=100);
            }
        }
    }
}
//                      <- Linear text panel ->
module LText(OnOff,Tx,Ty,Font,Size,Content){
    if(OnOff==1) {
        translate([Tx,Ty,Thick+.5]) {
            linear_extrude(height = 0.5){
                text(Content, size=Size, font=Font);
            }
        }
    }
}
//                     <- Circular text panel->
module CText(OnOff,Tx,Ty,Font,Size,TxtRadius,Angl,Turn,Content){
    if(OnOff==1) {
        Angle = -Angl / len(Content);
        translate([Tx,Ty,Thick+.5]) {
            for (i= [0:len(Content)-1] ){
                rotate([0,0,i*Angle+90+Turn]) {
                    translate([0,TxtRadius,0]) {
                        linear_extrude(height = 0.5){
                            text(Content[i], font = Font, size = Size,  valign ="baseline", halign ="center");
                        }
                    }
                }
            }
        }
    }
}
////////////////////// <- New module Panel -> //////////////////////
module FPanL(){
    difference(){
        color(Couleur2) {
            Panel(Length,Width,Thick,Filet);
        }
        rotate([90,0,90]){
            color(Couleur2){
//                     <- Cutting shapes from here ->
//                SquareHole  (0,20,20,15,10,1); //(On/Off, Xpos,Ypos,Length,Width,Filet)
//                CylinderHole(1,26,16,8);       //(On/Off, Xpos, Ypos, Diameter)
//                CylinderHole(1,40,16,8);       //(On/Off, Xpos, Ypos, Diameter)
//                CylinderHole(1,54,16,8);       //(On/Off, Xpos, Ypos, Diameter)
//                SquareHole  (1,20,50,80,30,3);
//                SquareHole  (1,120,20,30,60,3);
//                            <- To here ->
            }
        }
    }

    color(Couleur1){
        translate ([-.5,0,0]) {
            rotate([90,0,90]){
//                      <- Adding text from here ->
                LText(0,20,83,"Arial Black",4,"Digital Screen");//(On/Off, Xpos, Ypos, "Font", Size, "Text")
                //LText(1,24,5,"Arial Black",5,"1");
                //LText(1,38,5,"Arial Black",5,"2");
                //LText(1,52,5,"Arial Black",5,"3");

                CText(0,93,29,"Arial Black",4,10,180,0,"1 . 2 . 3 . 4 . 5 . 6");//(On/Off, Xpos, Ypos, "Font", Size, Diameter, Arc(Deg), Starting Angle(Deg),"Text")
//                            <- To here ->
            }
        }
    }
}

module BPanL(){
    difference(){
        color(Couleur2){
            Panel(Length,Width,Thick,Filet);
        }

        rotate([90,0,90]){
            color(Couleur2){
    //                     <- Cutting shapes from here ->
                SquareHole  (1,20,5,15,11,1); //(On/Off, Xpos,Ypos,Length,Width,Filet)
                CylinderHole(0,20,15,8);       //(On/Off, Xpos, Ypos, Diameter)
    //                            <- To here ->
            }
        }
    }

    color(Couleur1){
        translate ([-.5,0,0]){
            rotate([90,0,90]){
    //                      <- Adding text from here ->
                LText(0,20,83,"Arial Black",4,"Digital Screen");//(On/Off, Xpos, Ypos, "Font", Size, "Text")
                LText(0,120,83,"Arial Black",4,"Level");
                LText(0,20,11,"Arial Black",6,"  1     2      3");
                CText(0,93,29,"Arial Black",4,10,180,0,"1 . 2 . 3 . 4 . 5 . 6");//(On/Off, Xpos, Ypos, "Font", Size, Diameter, Arc(Deg), Starting Angle(Deg),"Text")
    //                            <- To here ->
            }
        }
    }
}

/////////////////////////// <- Main part -> /////////////////////////
if(TShell)
// Coque haut - Top Shell
        color( Couleur1,1){
            translate([0,Width,Height+0.2]){
                rotate([0,180,180]){
                        Coque();
                        }
                }
        }

if(BShell) {
    // Coque bas - Bottom shell
    if(PCB1_TestFit){
        translate([3*Thick,Thick+3,Thick]){
            square ([PCB1Length+8,PCB1Width+8]);
        }
    } else {
        color(Couleur1){
            Coque();
        }
    }

    // Pied support PCB - PCB feet
    if (PCBFeet) {
        // Feet
        translate([PCB1PosX,PCB1PosY,0]){
            Feet(PCB1FootHeight, PCB1FootDia, PCB1FootHole, PCB1Length, PCB1Width, "PCB-1");
        }
        //translate([PCB2PosX,PCB2PosY,0]){
        //    Feet(PCB2FootHeight, PCB2FootDia, PCB2FootHole, PCB2Length, PCB2Width, "PCB-2");
        //}
    }
}

// Panneau avant - Front panel  <<<<<< Text and holes only on this one.
//rotate([0,-90,-90])
if(FPanL)
        translate([Length-(Thick*2+m/2),Thick+m/2,Thick+m/2])
        FPanL();

//Panneau arrière - Back panel
if(BPanL)
        translate([Thick+m/2,Thick+m/2,Thick+m/2])
        BPanL();