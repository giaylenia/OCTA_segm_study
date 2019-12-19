### How to use
Divide your images and masks in training and test folders. 

**Step 1:** Use Create_training_patches to create the images to use as input to the network

**Step 1.1:** Use Create_validation_patches to move a 10% of images of the training folder in the validation folder 

**Step 2:** Use Create_test_patches to generate test input images

**Step 3:** Use Unet_model to train/validate your model  

**Step 4:** Use Predict_Unet to produce the probability maps

