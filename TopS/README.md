Install GUDHI: instruction [here](https://gudhi.inria.fr/python/latest/installation.html)
 
You can find the tutorial [here](https://gudhi.inria.fr/python/latest/cubical_complex_user.html)

Step 1: Create the folder with the binary images (binary_images)

Step 2: Create the folder with the ground truth images (gt_images)

Step 3: convert binary images and ground truth into [Perseus format](https://gudhi.inria.fr/python/latest/fileformats.html) using the matlab script image2txt. The script save the .txt files inside the specified subfolder in OCTAcubinalcomplex folder

Step 4: use TopS.ipynb to compute Betti numbers and TopS. 