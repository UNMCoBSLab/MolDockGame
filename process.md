step1: get the protein and ligand files from cameraX
    open chimeraX; choose the protein of interest
    goto "Select" in menu; choose "Residues"; select the ligand of interest
    goto "Actions" in menu; choose "Atoms/Bonds"; select the "delete"; now we only have the protein
    goto "Molecule Display" in submenu; hide Atoms, hide Cartoons, show Surfaces
    goto "File" in menu; choose "Save.."; save 2 files to the direcotry of interest
    file1: PDB file of protein; this is used for atoms, energy, and charges
    file2: wavefront OBJ file of protein; this is used for 3d rendering in app
    close and reopen chimeraX; choose the protein of interest
    goto "Select" in menu; choose "Residues"; select the ligand of interest
    goto "Select" in menu; choose "Invert"; select the protein
    goto "Actions" in menu; choose "Atoms/Bonds"; select the "delete"; now we only have the ligand of interest
    goto "Molecule Display" in submenu; hide Atoms, hide Cartoons, show Surfaces
    goto "File" in menu; choose "Save.."; save 2 files to the direcotry of interest
    file3: PDB file of ligand; this is used for atoms, energy, and charges
    file4: wavefront OBJ file of ligand; this is used for 3d rendering in app


step2: add hydrogens to both ligand and protein
    use "reduce" tool to do this
    https://github.com/rlabduke/reduce
    input: ligand and protein PDB files  xxx.pdb
    output: ligand and protein with hydrogen PDB files   xxx_HIS.pdb
    install in linux; then run terminal line commands:
        ...

step3: calculating the charges of ligand atoms with "antechamber" tools
    http://ambermd.org/antechamber/ac.html#antechamber
    input: ligand PDB file with hydrogen;  xxx_HIS.pdb
    output: xxxligand.prepin file(get the charge info with atom names)
    install in linux; then run terminal line commands:
        ...

step4: remove the water from protein(no water in ligand); get protein atoms coordiantes, electrostatic, sigma and epsilon energy
get ligand atoms coordiantes, sigma and epsilon energy
    use molecule_processing.ipynb to do it; running on google colab is recommended
    input: xxxligand.prepin, xxxligand_HIS.pdb, xxxprotein_HIS.pdb
    output: protein.txt, ligand.txt
    each line of the two txt files are seperated by "," 
    on each line; atom ID,x,y,z,charge,sigma,epsilon 

step5: put all the files in the flutter resource folder
    file list: protein.txt, ligand.txt, protein.obj, ligand.obj
    do not forget to regiester these files in the flutter resource folder
    an example is:
    """
        assets:
        - assets/1fkf/1fkf.obj
        - assets/1fkf/FK5.obj
        - assets/1fkf/ligand.txt
        - assets/1fkf/protein.txt
    """

alternative step: maybe you would need to reduce the resolution of the proteins' vertices such that there are less pressure on the hardwares. Please refer to "molecule_processing.ipynb" for that. Hopefully this won't be an issue anymore for you from the future~