# UMMDp - Unified Material Model Driver for Plasticity

## Pre-requisites

* Fortran compiler

## Usage

### Preparation of program source files

Concatenate the UMMDp source files into one single file with the plug-in file first. Simply use the batch files (.sh/.bat) or run each command separately.

#### Unix/Linux

````
$ compile.sh
````

  or

````
$ cp source/plug_ummdp_abaqus.f source/tmp.f
$ cat source/ummdp*.f >> source/tmp.f
$ mv source/tmp.f compiled/UMMDp.f
````

#### Windows

````
$ compile.bat
````

  or

````
> copy "source\plug_ummdp_abaqus.f" "source\tmp.f"
> type "source\ummdp*.f" >> "source\tmp.f"
> move "source\tmp.f" "compiled\UMMDp.f"
````

### Preparation of the input file

This section describes the keywords in Abaqus input data file for use in the UMMDp.

1. Definition of the principal axis for the material anisotropy (for more information, please refer to Abaqus's manual)
````
*ORIENTATION, NAME=ORI-1
1., 0., 0., 0., 1., 0.
3, 0.
````

2. Definition of the material model (more details are provided later)
````
*MATERIAL, NAME=UMMDp
*USER MATERIAL, CONSTANTS=27
0, 0, 1000.0, 0.3, 2, -0.069, 0.936, 0.079,
1.003, 0.524, 1.363, 0.954, 1.023, 1.069, 0.981, 0.476,
0.575, 0.866, 1.145, -0.079, 1.404, 1.051, 1.147, 8.0,
0, 1.0, 0
````

3. Define the number of internal state variables (SDV)

Set the number of state variables equal to 1+NTENS, where NTENS is the number of
components of the tensor variables. NTENS=3 for plane stress or a shell element,
and NTENS=6 for a solid element. The 1st state variable is reserved for the equivalent plastic
strain, and NTENS is reserved for the plastic strain components. The following ex-
ample corresponds to a solid element without kinematic hardening:
````
*DEPVAR
7,
````
In the case of kinematic hardening, the number of internal state variables corresponds
to the equivalent plastic strain, plastic strain components and components of each
partial back-stress tensor.

4. Define the user output variables (UVARM)

UMMDp can output three user output variables:

- UVARM(1): current equivalent stress (the value calculated by substituting the stress com-
ponents for the yield function)

- UVARM(2): current yield stress (the value calculated by substituting the equivalent plastic
strain for the function of the isotropic hardening curve)

- UVARM(3:8): current components of the total back-stress tensor
````
*USER OUTPUT VARIABLES
8,
````

5. Define output variables for post processing

This keyword controls the output variables (e.g. equivalent plastic strain and equiv-
alent stress) for post processing.
````
*OUTPUT, FIELD
*ELEMENT OUTPUT
SDV, UVARM
````
