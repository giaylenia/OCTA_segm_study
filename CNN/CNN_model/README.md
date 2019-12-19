### How to use
Divide your images and masks in training and test folders. 

**Step 1:** Use Create_training_all to create the images to use as input to the network

**Step 1.1:** Use Create_validation to create training and validation starting fron the training folder created at step 1

**Step 2:** Use Create_test to generate test input images and a txt file with labels 

**Step 3:** Use CNN_model to train/validate your model  

**Step 4:** Use Predict_CNN to predict vessel/background probabilities for each pixel

