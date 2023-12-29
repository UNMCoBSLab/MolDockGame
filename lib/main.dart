/*
Copyright 2023 UNM Jacobson Lab
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import 'dart:math';
import 'package:dock_it/atom.dart';
import 'package:dock_it/calculation.dart';
import 'package:dock_it/molecule.dart';
import 'package:flutter/material.dart';
import 'dart:io'; //does not support web application

void main() {
  runApp(const MyApp());  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DockIt',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DockIt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Offset _offset = Offset.zero;
  int argument = 10;
  
  List<List<double>> proteinPoints = [];  //for the dotted rendering of the protein
  List<List<double>> proteinMesh = [];  //for the triangle rendering of the protein
  List<Atom> proteinAtoms = [];  //for energy calculation

  List<List<double>> ligandPoints = []; //for the dotted rendering of the ligand
  List<List<int>> ligandMesh = [];  //for the triangle rendering of the ligand
  List<Atom> ligandAtoms = [];  //for energy calculation

  //for triangle render of the protein, full resolution is hard to rotate
  List<List<int>> simpleProteinMesh = [];
  List<List<double>> simpleProteinPoints = [];


  double energy = 0.0;
  int score = 0;
  int bestScore = 0;
  String displayText = ""; 
  
  List<String> moleculeButtonTexts = ["Rotate  ligand","Rotate protein"];
  int moleculeButtonIdx = 0;
  List<String> renderButtonTexts = ["Render mode1","Render mode2"];
  int renderButtonIdx = 0;
  List<String> gradientDescend = ["GD start","GD stop"];
  int GD_Idx = 0;

  int diretionButton = 5; //up 1; down 2; left 3; right 4 

  List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(value: "1fkf", child: Text("1fkf")),
      // Add more items here
    ];
  String? selectedValue;

  _MyHomePageState() {
    proteinPoints = Molecule.inputMoleculeShape("assets/1fkf/1fkf.obj", 0, 8, 0);
    ligandPoints = Molecule.inputMoleculeShape("assets/1fkf/FK5.obj", 20, 8, 0);
    ligandMesh = Molecule.inputMesh("assets/1fkf/FK5.obj");

    proteinAtoms = Molecule.inputMolecule("assets/1fkf/protein.txt", 0, 8, 0);
    ligandAtoms =  Molecule.inputMolecule("assets/1fkf/ligand.txt", 20, 8, 0);
    
    simpleProteinMesh = Molecule.inputSimpleMeshCoor("assets/1fkf/low_reolution_facets.txt", 0, 8, 0);
    simpleProteinPoints = Molecule.inputSimpleMolecule("assets/1fkf/low_reolution_points.txt", 0, 8, 0);
  }

  void updateState() {
    List<double> energyDetails = Calculation.calculateEnergy(ligandAtoms,proteinAtoms);
    energy = energyDetails[0]+energyDetails[1];
    score = Calculation.calculateScore(energy); 
    if(score>bestScore) {
      bestScore = score;
    }
    
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => showAlertDialog(context));
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Welcome"),
          content: Text("Click on Rotate button to change rotation mode. \nClick on Render button to change the rendering mode."),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D protein")),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(""),
            Text(""),
            Text(""),
            Text(""),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  //updates the positions, rotations, energies, and scores
                  _offset += details.delta;                  
                  if(moleculeButtonIdx==0){
                    rotateDotsPosition(ligandPoints, ligandAtoms, _offset.dy*0.0001, _offset.dx*0.0001, 0.0);   

                  } else if(moleculeButtonIdx==1) {
                    rotateDotsPosition(proteinPoints, proteinAtoms, _offset.dy*0.0001, _offset.dx*0.0001, 0.0);  
                    rotateMeshPosition(simpleProteinPoints,_offset.dy*0.0001, _offset.dx*0.0001, 0.0);

                  }
                  
                  List<double> energyDetails = Calculation.calculateEnergy(ligandAtoms,proteinAtoms);
                  energy = energyDetails[0]+energyDetails[1];
                  score = Calculation.calculateScore(energy); 
                  if(score>bestScore) {
                    bestScore = score;
                  }
                });   
              },
              child: CustomPaint(
                size:Size(300,300),
                painter: MyPainter(proteinPoints, ligandPoints, renderButtonIdx, simpleProteinMesh, simpleProteinPoints, ligandMesh, argument),                
              ),
            ),
            
            //Text('The total energy: $energy', 
              //style: TextStyle(fontSize: 24),),

            Text('The score: $score', 
              style: TextStyle(fontSize: 24),),

            Text("Best score: $bestScore",
              style: TextStyle(fontSize: 24)),  

            Row(
              children: <Widget>[
                Text("                                                       "),
                ElevatedButton(
                  onPressed: () {
                    // Handle up button press
                    moveDotsPosition(ligandPoints, ligandAtoms, 0, -0.1);
                    updateState();
                  },
                  child: Icon(Icons.arrow_upward),
                )
              ]
            ),
            
            Row(
              children: <Widget>[
                Text("                                     "),

                //up 1; down 2; left 3; right 4 
                ElevatedButton(
                  onPressed: () {
                    // Handle left button press
                    moveDotsPosition(ligandPoints, ligandAtoms, -0.1, 0);
                    updateState();
                  },
                  child: Icon(Icons.arrow_back),
                ),

                ElevatedButton(
                  onPressed: () {
                    // Handle down button press
                    moveDotsPosition(ligandPoints, ligandAtoms, 0, 0.1);
                    updateState();
                  },
                  child: Icon(Icons.arrow_downward),
                ),  

                ElevatedButton(
                  onPressed: () {
                    // Handle right button press
                    moveDotsPosition(ligandPoints, ligandAtoms, 0.1, 0);
                    updateState();
                  },
                  child: Icon(Icons.arrow_forward),
                ),

                Text("                    "),

                DropdownButton<String>(
                  value: selectedValue,
                  items: items,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                  hint: Text("Choose another protein"),
                ),
              ]

              
            ),
            Text("")
          ],
        )
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[            

            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  // When the button is pressed, ToggleButtons states is changed.
                  moleculeButtonIdx++;    
                  moleculeButtonIdx = moleculeButtonIdx%2;
                });
              },
              //icon: const Icon(Icons.screen_rotation_outlined),
              //https://api.flutter.dev/flutter/material/Icons-class.html
              label: Text(moleculeButtonTexts[moleculeButtonIdx%3],style: TextStyle(fontSize: 24)),
            ),

            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  // When the button is pressed, ToggleButtons states is changed.
                  renderButtonIdx++; 
                  renderButtonIdx = renderButtonIdx%2;        
                });
              },
              //icon: const Icon(Icons.screen_rotation_outlined),
              label: Text(renderButtonTexts[renderButtonIdx%2], style: TextStyle(fontSize: 24)),
            ),

            /*
            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  // When the button is pressed, ToggleButtons states is changed.
                  GD_Idx++; 
                  GD_Idx = GD_Idx%2;        
                });
              },
              //icon: const Icon(Icons.screen_rotation_outlined),
              label: Text(gradientDescend[GD_Idx%2]),
            ),
            */

            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  // When the button is pressed, ToggleButtons states is changed.
                  argument++;       
                });
              },
              //icon: const Icon(Icons.screen_rotation_outlined),
              label: Text("Zoom in", style: TextStyle(fontSize: 24)),
            ),

            FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  // When the button is pressed, ToggleButtons states is changed.
                  argument--;       
                });
              },
              //icon: const Icon(Icons.screen_rotation_outlined),
              label: Text("Zoom out", style: TextStyle(fontSize: 24)),
            ),

          ],
        ),
      )
    
    );
  }

  void rotateDotsPosition(List<List<double>> moleculeShape, List<Atom> molecule, double rx, double ry, double rz) {

    //rotate the dots shape
    double x_mean = 0.0;
    double y_mean = 0.0;
    double z_mean = 0.0;
    
    for(int i=0; i<moleculeShape.length; i++) {
      x_mean+=moleculeShape[i][0];
      y_mean+=moleculeShape[i][1];
      z_mean+=moleculeShape[i][2];
    }

    x_mean/=moleculeShape.length;
    y_mean/=moleculeShape.length;
    z_mean/=moleculeShape.length;

    for(int i=0; i<moleculeShape.length; i++) {
      moleculeShape[i][0]-=x_mean;
      moleculeShape[i][1]-=y_mean;
      moleculeShape[i][2]-=z_mean;
    }

    for(int i=0; i<moleculeShape.length; i++) {
      List<double> coor = moleculeShape[i];
      double x = coor[0];
      double y = coor[1];
      double z = coor[2];

      //perform the rotations
      //rotate x
      double rxx = x;
      double rxy = y*cos(rx) + z*sin(rx);
      double rxz = z*cos(rx) - y*sin(rx);

      //rotate y
      double ryx = rxx*cos(ry) - rxz*sin(ry);
      double ryy = rxy;
      double ryz = rxx*sin(ry) + rxz*cos(ry);

      //rotate z
      //rzx rzy rzz are the coordinates after rotation
      double rzx = ryx*cos(rz) - ryy*sin(rz);
      double rzy = ryx*sin(rz) + ryy*cos(rz);
      double rzz = ryz;
      
      moleculeShape[i][0] = rzx+x_mean;
      moleculeShape[i][1] = rzy+y_mean;
      moleculeShape[i][2] = rzz+z_mean;
    }


    //rotate the molecule atoms
    x_mean = 0.0;
    y_mean = 0.0;
    z_mean = 0.0;
    for(int i=0; i<molecule.length; i++) {
      x_mean+=molecule[i].x;
      y_mean+=molecule[i].y;
      z_mean+=molecule[i].z;
    }

    x_mean/=molecule.length;
    y_mean/=molecule.length;
    z_mean/=molecule.length;

    for(int i=0; i<molecule.length; i++) {
      molecule[i].x-=x_mean;
      molecule[i].y-=y_mean;
      molecule[i].z-=z_mean;
    }

    for(int i=0; i<molecule.length; i++) {
      double x = molecule[i].x;
      double y = molecule[i].y;
      double z = molecule[i].z;

      //perform the rotations
      //rotate x
      double rxx = x;
      double rxy = y*cos(rx) + z*sin(rx);
      double rxz = z*cos(rx) - y*sin(rx);

      //rotate y
      double ryx = rxx*cos(ry) - rxz*sin(ry);
      double ryy = rxy;
      double ryz = rxx*sin(ry) + rxz*cos(ry);

      //rotate z
      //rzx rzy rzz are the coordinates after rotation
      double rzx = ryx*cos(rz) - ryy*sin(rz);
      double rzy = ryx*sin(rz) + ryy*cos(rz);
      double rzz = ryz;
      
      molecule[i].x = rzx+x_mean;
      molecule[i].y = rzy+y_mean;
      molecule[i].z = rzz+z_mean;
    }

  }

  void rotateMeshPosition(List<List<double>> simpleMoleculePoints, double rx, double ry, double rz){
    
    //rotate the simple vertices of the mesh rendering
    double x_mean = 0.0;
    double y_mean = 0.0;
    double z_mean = 0.0;
    for(int i=0; i<simpleMoleculePoints.length; i++) {
      x_mean+=simpleMoleculePoints[i][0];
      y_mean+=simpleMoleculePoints[i][1];
      z_mean+=simpleMoleculePoints[i][2];
    }

    x_mean/=simpleMoleculePoints.length;
    y_mean/=simpleMoleculePoints.length;
    z_mean/=simpleMoleculePoints.length;

    for(int i=0; i<simpleMoleculePoints.length; i++) {
      simpleMoleculePoints[i][0]-=x_mean;
      simpleMoleculePoints[i][1]-=y_mean;
      simpleMoleculePoints[i][2]-=z_mean;
    }

    for(int i=0; i<simpleMoleculePoints.length; i++) {
      List<double> coor = simpleMoleculePoints[i];
      double x = coor[0];
      double y = coor[1];
      double z = coor[2];

      //perform the rotations
      //rotate x
      double rxx = x;
      double rxy = y*cos(rx) + z*sin(rx);
      double rxz = z*cos(rx) - y*sin(rx);

      //rotate y
      double ryx = rxx*cos(ry) - rxz*sin(ry);
      double ryy = rxy;
      double ryz = rxx*sin(ry) + rxz*cos(ry);

      //rotate z
      //rzx rzy rzz are the coordinates after rotation
      double rzx = ryx*cos(rz) - ryy*sin(rz);
      double rzy = ryx*sin(rz) + ryy*cos(rz);
      double rzz = ryz;
      
      simpleMoleculePoints[i][0] = rzx+x_mean;
      simpleMoleculePoints[i][1] = rzy+y_mean;
      simpleMoleculePoints[i][2] = rzz+z_mean;
    }
    
  }

  void moveDotsPosition(List<List<double>> moleculeShape, List<Atom> molecule, double dx, double dy) {
    for(int i=0; i<moleculeShape.length; i++) {
      moleculeShape[i][0] += dx;
      moleculeShape[i][1] += dy;
    }    

    for(int i=0; i<molecule.length; i++) {
      molecule[i].x += dx;
      molecule[i].y += dy;
    }    
    
    setState(() {           
      List<double> energyDetails = Calculation.calculateEnergy(ligandAtoms,proteinAtoms);
      energy = energyDetails[0]+energyDetails[1];
      score = Calculation.calculateScore(energy); 
    }); 

  }
  

}

class MyPainter extends CustomPainter {

  List<List<double>> proteinPoints = [];  //for the dotted rendering of the protein
  List<List<double>> ligandPoints = []; //for the dotted rendering of the ligand

  //for mesh rendering
  List<List<int>> simpleProteinMesh = [];
  List<List<double>> simpleproteinCoordinates = [];
  List<List<int>> ligandMesh = [];

  int renderState = 0;
  int argument = 10;

  double rx_protein = 0.0;
  double ry_protein = 0.0;
  double rz_protein = 0.0;

  MyPainter(List<List<double>> p, List<List<double>> l, int state, List<List<int>> p_mesh, List<List<double>> p_mesh_coor, List<List<int>> l_mesh, int arg) {
    proteinPoints = p;
    ligandPoints = l;
    renderState = state;
    simpleProteinMesh = p_mesh;
    simpleproteinCoordinates = p_mesh_coor;
    ligandMesh = l_mesh;
    argument = arg;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    if(renderState==0){
      dottedRender(canvas, size, proteinPoints, Colors.grey, argument);
      dottedRender(canvas, size, ligandPoints, Colors.blue, argument);
    } else {
      lowResolutionTriangleRender(canvas, size, argument); //10,000 facets are the maxium that can be handled
      triangleRender(canvas, size, argument); //for ligand triangle rendering
    }
    
  }

  void dottedRender(Canvas canvas, Size size, List<List<double>> molecule, Color c, int argument) {
    double radius = 0.5; 
    //int argument = 10;
    for(int i=0; i<molecule.length; i++) {
      List<double> coor = molecule[i];
      double x = coor[0];
      double y = coor[1];
      double z = coor[2];
      canvas.drawCircle(Offset(argument*x,argument*y), radius, Paint()..color = c);
    }
  }  

  void lowResolutionTriangleRender(Canvas canvas, Size size, int argument) {
    List<List<double>> temp1 = [];
    //int argument = 10;
    for(int i=0; i<proteinPoints.length; i++) {
      List<double> coor = proteinPoints[i];
      double x = coor[0];
      double y = coor[1];
      double z = coor[2];

      double rx = rx_protein;
      double ry = ry_protein;
      double rz = rz_protein;

      //perform the rotations
      //rotate x
      double rxx = x;
      double rxy = y*cos(rx) + z*sin(rx);
      double rxz = z*cos(rx) - y*sin(rx);

      //rotate y
      double ryx = rxx*cos(ry) - rxz*sin(ry);
      double ryy = rxy;
      double ryz = rxx*sin(ry) + rxz*cos(ry);

      //rotate z
      double rzx = ryx*cos(rz) - ryy*sin(rz);
      double rzy = ryx*sin(rz) + ryy*cos(rz);
      double rzz = ryz;

      temp1.add([rzx*argument, rzy*argument, rzz*argument]);
    }

    List<List<double>> temp2 = [];
    for(int i=0; i<simpleproteinCoordinates.length; i++) {
      List<double> coor = simpleproteinCoordinates[i];
      double x = coor[0];
      double y = coor[1];
      double z = coor[2];

      double rx = rx_protein;
      double ry = ry_protein;
      double rz = rz_protein;

      //perform the rotations
      //rotate x
      double rxx = x;
      double rxy = y*cos(rx) + z*sin(rx);
      double rxz = z*cos(rx) - y*sin(rx);

      //rotate y
      double ryx = rxx*cos(ry) - rxz*sin(ry);
      double ryy = rxy;
      double ryz = rxx*sin(ry) + rxz*cos(ry);

      //rotate z
      double rzx = ryx*cos(rz) - ryy*sin(rz);
      double rzy = ryx*sin(rz) + ryy*cos(rz);
      double rzz = ryz;

      temp2.add([rzx*argument, rzy*argument, rzz*argument]);
    }

    //draw triangles
    for(int i=0; i<simpleProteinMesh.length; i++) {
      //draw the black edges
      List<double> p1 = temp2[simpleProteinMesh[i][0]];
      List<double> p2 = temp2[simpleProteinMesh[i][1]];
      List<double> p3 = temp2[simpleProteinMesh[i][2]];
      
      Color lineColor = Color.fromARGB(255, 239, 235, 235);
      canvas.drawLine(Offset(p1[0],p1[1]), Offset(p2[0],p2[1]), Paint()
      ..color = lineColor
      ..strokeWidth = 1);

      canvas.drawLine(Offset(p1[0],p1[1]), Offset(p3[0],p3[1]), Paint()
      ..color = lineColor
      ..strokeWidth = 1);

      canvas.drawLine(Offset(p2[0],p2[1]), Offset(p3[0],p3[1]), Paint()
      ..color = lineColor
      ..strokeWidth = 1);
      

      //draw the inside of the triangle
      final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.amber, Colors.blue], // Your gradient colors
      ).createShader(Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)))
      
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

      final path = Path()
      ..moveTo(p1[0],p1[1])
      ..lineTo(p2[0],p2[1])
      ..lineTo(p3[0],p3[1])
      ..close();

      canvas.drawPath(path, paint);
      
    }    
  } 

  void triangleRender(Canvas canvas, Size size, int argument) {
    List<List<double>> temp = [];
    //int argument = 10;
    for(int i=0; i<ligandPoints.length; i++) {
      List<double> coor = ligandPoints[i];
      double x = coor[0];
      double y = coor[1];
      double z = coor[2];

      double rx = rx_protein;
      double ry = ry_protein;
      double rz = rz_protein;

      //perform the rotations
      //rotate x
      double rxx = x;
      double rxy = y*cos(rx) + z*sin(rx);
      double rxz = z*cos(rx) - y*sin(rx);

      //rotate y
      double ryx = rxx*cos(ry) - rxz*sin(ry);
      double ryy = rxy;
      double ryz = rxx*sin(ry) + rxz*cos(ry);

      //rotate z
      double rzx = ryx*cos(rz) - ryy*sin(rz);
      double rzy = ryx*sin(rz) + ryy*cos(rz);
      double rzz = ryz;

      temp.add([rzx*argument, rzy*argument, rzz*argument]);
    }
    //draw triangles
    for(int i=0; i<ligandMesh.length; i++) {
      //draw the black edges
      List<double> p1 = temp[ligandMesh[i][0]];
      List<double> p2 = temp[ligandMesh[i][1]];
      List<double> p3 = temp[ligandMesh[i][2]];

      
      Color lineColor = Color.fromARGB(255, 243, 238, 238);
      canvas.drawLine(Offset(p1[0],p1[1]), Offset(p2[0],p2[1]), Paint()
      ..color = lineColor
      ..strokeWidth = 1);

      canvas.drawLine(Offset(p1[0],p1[1]), Offset(p3[0],p3[1]), Paint()
      ..color = lineColor
      ..strokeWidth = 1);

      canvas.drawLine(Offset(p2[0],p2[1]), Offset(p3[0],p3[1]), Paint()
      ..color = lineColor
      ..strokeWidth = 1);
      

      //draw the inside of the triangle
      final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

      final path = Path()
      ..moveTo(p1[0],p1[1])
      ..lineTo(p2[0],p2[1])
      ..lineTo(p3[0],p3[1])
      ..close();

      canvas.drawPath(path, paint);
      
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}