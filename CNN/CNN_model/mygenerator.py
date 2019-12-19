# from https://stanford.edu/~shervine/blog/keras-how-to-generate-data-on-the-fly

from keras.utils import to_categorical
import matplotlib.pyplot as plt
import numpy as np
import keras
import cv2

class DataGenerator(keras.utils.Sequence):
    'Generates data for Keras'
    def __init__(self, list_IDs, labels, batch_size=100, dim=61, n_channels=1,
                 n_classes=2, shuffle=True):
        'Initialization'

        self.dim = dim
        self.batch_size = batch_size
        self.labels = labels
        self.list_IDs = list_IDs
        self.n_channels = n_channels
        self.n_classes = n_classes
        self.shuffle = shuffle
        self.on_epoch_end()

    def __len__(self):
        'Denotes the number of batches per epoch'
        return int(np.floor(len(self.list_IDs) / self.batch_size))

    def __getitem__(self, index):
        'Generate one batch of data'
        # Generate indexes of the batch
        indexes = self.indexes[index*self.batch_size:(index+1)*self.batch_size]

        # Find list of IDs
        list_IDs_temp = [self.list_IDs[k] for k in indexes]

        # Generate data
        X, y = self.__data_generation(list_IDs_temp)

        return X, y

    def on_epoch_end(self):
        'Updates indexes after each epoch'
        self.indexes = np.arange(len(self.list_IDs))
        if self.shuffle == True:
            np.random.shuffle(self.indexes)

    def __data_generation(self, list_IDs_temp):
        'Generates data containing batch_size samples' # X : (n_samples, dim, dim n_channels)
        # Initialization
        X = np.empty((self.batch_size, self.dim , self.dim))
        y = np.empty((self.batch_size), dtype=int)

        # Generate data
        for i, ID in enumerate(list_IDs_temp):
            # Store sample
            X[i,:,:] = cv2.imread( ID,0 )/255.0
            
            # Store class
            y[i] = self.labels[ID]
        X = np.reshape( X, (self.batch_size, self.dim, self.dim, 1))

        return X, keras.utils.to_categorical(y, num_classes=self.n_classes)
