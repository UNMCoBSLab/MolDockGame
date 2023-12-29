import 'package:dock_it/atom.dart';
import 'dart:math';

class Calculation{
  static final double ENERGY_C = 332.0522173;
  
  static List<double> calculateEnergy(List<Atom> ligandAtoms, List<Atom> receptorAtoms) {
    List<double> totalEnergy = [0,0];

    //Get the number of atoms in both lists.
    int lCount = ligandAtoms.length;
    int rCount = receptorAtoms.length;

    double cTotal = 0;
    double vTotal = 0;

    for(int i=0; i<lCount; i++) // For every atom in the ligand,
    {
        Atom lAtom = ligandAtoms[i];
        for(int j=0; j<rCount; j++) // calculate the sum of its energy to every atom in the receptor.
        {
            //for easier reading
            Atom rAtom = receptorAtoms[j];

            double radius = distanceBetweenAtoms(lAtom,rAtom);
            //Calculate energy between two atoms
            double coloumbEnergy = energy_esp(lAtom.charge, rAtom.charge, radius);
            double vanderwaalEnergy = energy_vdw(lAtom.vdws, rAtom.vdws, lAtom.vdwe, rAtom.vdwe, radius);

            cTotal += coloumbEnergy;
            vTotal += vanderwaalEnergy;

            //totalEnergy += vanderwaalEnergy+coloumbEnergy;

            //totalEnergy += energyBetweenAtoms(lAtom, receptorAtoms.get(j));
        }
    }
    totalEnergy[0] = vTotal;
    totalEnergy[1] = cTotal;
    return totalEnergy;
  }

  ///
  ///distanceBetweenAtoms()
  ///Calculates the distance between two atoms based on their XYZ coordinates.
  ///@param a Atom one (ligand)
  ///@param b Atom two (receptor)
  ///@return Euclidian distance between Atom a and Atom b.
  ///
  static double distanceBetweenAtoms(Atom a, Atom b) {
      double x = (a.x)-b.x;
      double y = (a.y)-b.y;
      double z = (a.z)-b.z;

      x*=x;
      y*=y;
      z*=z;
      return sqrt(x+y+z);
  }

  ///
  /// Calculates coloumb potential between two atoms.
  /// @param q1 - charge of first point (Elementary Charge)
  /// @param q2 - charge of second point (Elementary Charge)
  /// @param r - radius between the atoms
  /// @return Energy calculated
  ///
  static double energy_esp(double q1,double q2,double r) {
      if(r>=12){
          return 0.0;
      }
      double q,nf;
      /* Find q */
      q = q1*q2;
      /* Find Energy */
      nf = ENERGY_C*q/r;
      /* Return this Energy */
      return nf;
  }


  ///
  /// Calculates van-der-waals Energy potential between two atoms.
  /// @param sigma1, sigma2 - D parameter for Van Der Waals (D6/D12)
  /// @param epsilon1, epsilon2 - E parameter for Van Der Waals (epsilon)
  /// @param r - radius between the atoms
  /// @return van-der-waal's Energy calculated from the given parameters.
  /// usage: energy_vdw(lAtom.vdws, rAtom.vdws, lAtom.vdwe, rAtom.vdwe, radius);
  ///
  static double energy_vdw(double sigma1,double sigma2,double epsilon1,double epsilon2,double r) {
    if(r>12){
        //return 0.0;
    }
    double d,d6,d12,e,aa,bb,d2,d4;
    /* Find D, D6 and D12 */
    d = (sigma1+sigma2)/r;
    d2 = d*d;
    d4 = d2*d2;
    d6 = d4*d2;
    d12 = d6*d6;
    /* Find E */
    e = sqrt(epsilon1*epsilon2);
    /* Find AA and BB */
    aa = 0.25*d12;
    bb = 0.50*d6;
    /* Return answer */
    return 4.0*e*(aa-bb);
  } 

  //parameter en is the sum of electrostatic and vdw energy
  static int calculateScore(double en) {
    double ENERGY_SCORE_LIMIT = 0.0;
    int energy_base_score = 0;
    int energy_factor = 1;

    double nen;
    double fac;
    int ret;

    /* Get no points for this */
    if (en >= ENERGY_SCORE_LIMIT) {
        return 0;
    }
    /* Find negative bonus */
    nen = 0;
    if (en < 0) {
        nen = en;
    }
    /* Find score */
    en -= ENERGY_SCORE_LIMIT;
    en = (-en);
    en += (nen * nen) ~/ 100;

    /* Magnify by factor */
    en *= energy_factor;

    /* Adjust with environment specific base score (if set) */
    ret = en.toInt() - energy_base_score;
    if (ret < 0) {
        ret = 0;
    }
    return ret;
  }

}