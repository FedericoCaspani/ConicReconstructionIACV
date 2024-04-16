# ConicReconstructionIACV
This repository implements a 3D conic reconstruction methods from multiple views.
For better understanding please read our report [Report_ConicReconstruction](Report_ConicReconstruction.pdf)

### Instructions
The repository contains two notebooks for the experiments:
- `main.m`
- `synthetic_data_experiment.n`

The first one is used for real images while the second one uses synthetic data.
The second one can be started without additional tunings.
`main.m` can be used with images present in the repository (in the various "set" directories containing also the related camera intrinsics parameters) using custom images.
The camera intrinsics parameters in the various set directories can be computed from the images in the "calibrazione_cam" directories.
There are different parameters at the beginning of the notebook:
- `calibrate_intrinsics`: if set to `1` the calibration phase will be started. (Be sure to write the correct location for the calibration images). If it is not set to `1` there must be a file called `cameraParameters.mat` containing a valid camera.
- `select_points`: if set to `1` the user will be prompted to select points on the conics in the image. If it not set to `1` there must be a file called `conics.mat` containing the data structure with all the conics matrices.
- `display`: if set to `1` additional plots will appear during the calibration of the extrinsic parameters.

If the reconstruction doesn't reconstruct all the conics or reconstruct additional wrong conics the parameter `epsilon` must be tuned. Lower values will match less pairs of conics.

If the 3D plot raises an error consider tuning the `range` variable for the 3D plot in Matlab. We however prefer visualizing the results using the equations found in the output file "Conic_and_Planes.txt": they can be pasted in the 3D Geogebra tool at https://geogebra.org/3d. The reconstructed conic will be the intersection of the cone and the plane. There is an interactive tool to achieve the intersection.
