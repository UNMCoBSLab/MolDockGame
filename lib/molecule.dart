import 'dart:io';
import 'package:dock_it/atom.dart';

class Molecule {
  
  //for the obj file
  static List<List<double>> inputMoleculeShape(String filePath, double center_X, double center_Y, double center_Z) {
    List<List<double>> molecule = [];
    double sumX = 0.0;
    double sumY = 0.0;
    double sumZ = 0.0;
    try{
      String contents = File(filePath).readAsStringSync();
      List<String> lines = contents.split("\n");
      for (String line in lines) {
        List<String> temp = line.split(" "); 
        if(temp[0]=="v") {
          double x = double.parse(temp[1]);
          double y = double.parse(temp[2]);
          double z = double.parse(temp[3]);
          molecule.add([x,y,z]);
          sumX += x;
          sumY += y;
          sumZ += z;
        }
      }
    } catch(e) {
      print("docking game(inputMolecule shape): reading file error happened!!");
      print(e);
    }
    print("moledule shape read in complete!");
    double avgX = sumX/molecule.length;
    double avgY = sumY/molecule.length;
    double avgZ = sumZ/molecule.length;
    //to move the coordinates mid point into (0,0,0)
    for(int i=0 ; i<molecule.length; i++) {
      molecule[i][0]-=avgX;
      molecule[i][1]-=avgY;
      molecule[i][2]-=avgZ;

      molecule[i][0]+=center_X;
      molecule[i][1]+=center_Y;
      molecule[i][2]+=center_Z;
    }
    return molecule;
  }

  static List<List<int>> inputMesh(String filePath) {
    List<List<int>> mesh = [];
    try{
      String contents = File(filePath).readAsStringSync();
      List<String> lines = contents.split("\n");
      for (String line in lines) {
        List<String> temp = line.split(" "); 
        if(temp[0]=="f") {
          int v1 = int.parse(temp[1].split("/")[0]);
          int v2 = int.parse(temp[2].split("/")[0]);
          int v3 = int.parse(temp[3].split("/")[0]);
          mesh.add([v1-1,v2-1,v3-1]);
        }
      }
    } catch(e) {
      print("docking game(inputMeshCoor): reading file error happened!!");
      print(e);
    }
    return mesh;
  }

  //for the txt file containing position, charge, sigma, epsilon, 
  //each line shoud follow this format:
  //atom ID,x,y,z,charge,sigma,epsilon 
  static List<Atom> inputMolecule(String filePath, double center_X, double center_Y, double center_Z) {
    List<List<double>> molecule = [];
    double sumX = 0.0;
    double sumY = 0.0;
    double sumZ = 0.0;
    try{
      String contents = File(filePath).readAsStringSync();
      List<String> lines = contents.split("\n");
      for (String line in lines) {
        List<String> temp = line.split(","); 
        if(temp.length==7) {
          double x = double.parse(temp[1]);
          double y = double.parse(temp[2]);
          double z = double.parse(temp[3]);          
          sumX += x;
          sumY += y;
          sumZ += z;
          double charge = double.parse(temp[4]);
          double sigma = double.parse(temp[5]);
          double epsilon = double.parse(temp[6]); 
          molecule.add([x,y,z,charge,sigma,epsilon]);
        }
      }
    } catch(e) {
      print("docking game(inputMolecule): reading file error happened!!");
      print(e);
    }
    print("moledule read in complete!");
    double avgX = sumX/molecule.length;
    double avgY = sumY/molecule.length;
    double avgZ = sumZ/molecule.length;
    //to move the coordinates mid point into (0,0,0)
    for(int i=0 ; i<molecule.length; i++) {
      molecule[i][0]-=avgX;
      molecule[i][1]-=avgY;
      molecule[i][2]-=avgZ;

      molecule[i][0]+=center_X;
      molecule[i][1]+=center_Y;
      molecule[i][2]+=center_Z;
    }
    
    List<Atom> result = [];
    for(int i=0 ; i<molecule.length; i++) {
      result.add(Atom(molecule[i][0], molecule[i][1], molecule[i][2], molecule[i][3], molecule[i][4], molecule[i][5]));
    }
    return result;
  }

  static List<List<int>> inputSimpleMeshCoor(String filePath, double center_X, double center_Y, double center_Z) {
    List<List<int>> mesh = [];
    try{
      String contents = File(filePath).readAsStringSync();
      List<String> lines = contents.split("\n");
      for (String line in lines) {
        line = line.trim();
        List<String> temp = line.split(" "); 
        List<int> face = [];
        if(temp.length!=3){
          continue;
        }
        for(String num in temp) {
          face.add(int.parse(num));
        }
        mesh.add(face);
      }
    } catch(e) {
      print("docking game(inputSimpleMeshCoor): reading file error happened!!");
      print(e);
    }
    return mesh;
  }

  static List<List<double>> inputSimpleMolecule(String filePath, double center_X, double center_Y, double center_Z) {
    List<List<double>> molecule = [];
    double sumX = 0.0;
    double sumY = 0.0;
    double sumZ = 0.0;
    try{
      String contents = File(filePath).readAsStringSync();
      List<String> lines = contents.split("\n");     
      for (String line in lines) {
        List<String> temp = line.split(" "); 
        if(temp.length!=3){
          continue;
        }
        double x = double.parse(temp[0]);
        double y = double.parse(temp[1]);
        double z = double.parse(temp[2]);
        molecule.add([x,y,z]);
        sumX += x;
        sumY += y;
        sumZ += z;
        
      }
    } catch(e) {
      print("docking game(inputSimpleMolecule): reading file error happened!!");
      print(e);
    }
    print("moledule read in complete!");
    double avgX = sumX/molecule.length;
    double avgY = sumY/molecule.length;
    double avgZ = sumZ/molecule.length;
    //to move the coordinates mid point into (0,0,0)
    for(int i=0 ; i<molecule.length; i++) {
      molecule[i][0]-=avgX;
      molecule[i][1]-=avgY;
      molecule[i][2]-=avgZ;

      molecule[i][0]+=center_X;
      molecule[i][1]+=center_Y;
      molecule[i][2]+=center_Z;
    }
    return molecule;
  }

}