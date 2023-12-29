import 'dart:math';

class Atom {
    /**
     * X,Y,Z: The atom's position
     */
    double x;
    double y;
    double z;

    /**
     * Charge in elementary charge units
     */
    double charge;

    /**
     * Van der waals parameter EPSILON and SIGMA
     */
    double vdwe;
    double vdws;

    Atom(this.x,this.y,this.z,this.charge,this.vdws,this.vdwe);
    
    
}