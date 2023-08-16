//2D mesh script for ResIPy (run the following in gmsh to generate a triangular mesh with topograpghy)
Mesh.Binary = 0;//specify we want ASCII format
cl=1.00;//define characteristic length
//Define surface points
Point(1) = {-10.00,0.00,0.00,cl};//topography point
Point(2) = {0.00,0.00,0.00,cl};//electrode
Point(3) = {2.00,0.00,0.00,cl};//electrode
Point(4) = {4.00,0.00,0.00,cl};//electrode
Point(5) = {6.00,0.00,0.00,cl};//electrode
Point(6) = {8.00,0.00,0.00,cl};//electrode
Point(7) = {10.00,0.00,0.00,cl};//electrode
Point(8) = {12.00,0.00,0.00,cl};//electrode
Point(9) = {14.00,0.00,0.00,cl};//electrode
Point(10) = {16.00,0.00,0.00,cl};//electrode
Point(11) = {18.00,0.00,0.00,cl};//electrode
Point(12) = {20.00,0.00,0.00,cl};//electrode
Point(13) = {22.00,0.00,0.00,cl};//electrode
Point(14) = {24.00,0.00,0.00,cl};//electrode
Point(15) = {26.00,0.00,0.00,cl};//electrode
Point(16) = {28.00,0.00,0.00,cl};//electrode
Point(17) = {30.00,0.00,0.00,cl};//electrode
Point(18) = {32.00,0.00,0.00,cl};//electrode
Point(19) = {34.00,0.00,0.00,cl};//electrode
Point(20) = {36.00,0.00,0.00,cl};//electrode
Point(21) = {38.00,0.00,0.00,cl};//electrode
Point(22) = {40.00,0.00,0.00,cl};//electrode
Point(23) = {42.00,0.00,0.00,cl};//electrode
Point(24) = {44.00,0.00,0.00,cl};//electrode
Point(25) = {46.00,0.00,0.00,cl};//electrode
Point(26) = {56.00,0.00,0.00,cl};//topography point
//construct lines between each surface point
Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,5};
Line(5) = {5,6};
Line(6) = {6,7};
Line(7) = {7,8};
Line(8) = {8,9};
Line(9) = {9,10};
Line(10) = {10,11};
Line(11) = {11,12};
Line(12) = {12,13};
Line(13) = {13,14};
Line(14) = {14,15};
Line(15) = {15,16};
Line(16) = {16,17};
Line(17) = {17,18};
Line(18) = {18,19};
Line(19) = {19,20};
Line(20) = {20,21};
Line(21) = {21,22};
Line(22) = {22,23};
Line(23) = {23,24};
Line(24) = {24,25};
Line(25) = {25,26};
//add points below surface to make a fine mesh region
Point(27) = {-10.00,0.00,-15.33,cl*2.00};//base of smoothed mesh region
Point(28) = {-0.57,0.00,-15.33,cl*2.00};//base of smoothed mesh region
Point(29) = {8.86,0.00,-15.33,cl*2.00};//base of smoothed mesh region
Point(30) = {18.29,0.00,-15.33,cl*2.00};//base of smoothed mesh region
Point(31) = {27.71,0.00,-15.33,cl*2.00};//base of smoothed mesh region
Point(32) = {37.14,0.00,-15.33,cl*2.00};//base of smoothed mesh region
Point(33) = {46.57,0.00,-15.33,cl*2.00};//base of smoothed mesh region
Point(34) = {56.00,0.00,-15.33,cl*2.00};//base of smoothed mesh region
//make lines between base of fine mesh region points
Line(26) = {27,28};
Line(27) = {28,29};
Line(28) = {29,30};
Line(29) = {30,31};
Line(30) = {31,32};
Line(31) = {32,33};
Line(32) = {33,34};

//Adding boundaries
//end of boundaries.
//Add lines at leftmost side of fine mesh region.
Line(33) = {1,27};
//Add lines at rightmost side of fine mesh region.
Line(34) = {26,34};
//compile lines into a line loop for a mesh surface/region.
Line Loop(1) = {33, 26, 27, 28, 29, 30, 31, 32, -34, -25, -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1};

//Background region (Neumann boundary) points
cln=50.00;//characteristic length for background region
Point(35) = {-240.00,0.00,0.00,cln};//far left upper point
Point(36) = {-240.00,0.00,-153.33,cln};//far left lower point
Point(37) = {286.00,0.00,0.00,cln};//far right upper point
Point(38) = {286.00,0.00,-153.33,cln};//far right lower point
//make lines encompassing all the background points - counter clock wise fashion
Line(35) = {1,35};
Line(36) = {35,36};
Line(37) = {36,38};
Line(38) = {38,37};
Line(39) = {37,26};
//Add line loops and plane surfaces for the Neumann region
Line Loop(2) = {35, 36, 37, 38, 39, 34, -32, -31, -30, -29, -28, -27, -26, -33};
Plane Surface(1) = {1, 2};//Coarse mesh region surface

//Adding polygons
//end of polygons.
Plane Surface(2) = {1};//Fine mesh region surface

//Make a physical surface
Physical Surface(1) = {2, 1};

//End gmsh script
