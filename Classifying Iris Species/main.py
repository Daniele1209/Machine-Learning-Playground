import pandas as pd
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
import mglearn
import matplotlib
import numpy as np
# --- basic stuff ---

# we load the Bunch object ftom sklearn.datasets
iris_dataset = load_iris()

# get the description of the dataset
print(iris_dataset['DESCR'][:193] + "\n end")

# get species of the irises
print(iris_dataset['target_names'])

# get the features
print(iris_dataset['feature_names'])

# the shape of the data is the number of samples times the number of features
print(iris_dataset['data'].shape)

# ex: get the value for the first 3 samples
print(iris_dataset['data'][:3])

# 0 - setosa, 1 - versicolor, 2 - virginica
print(iris_dataset['target'])


# --- training and testing data ---

X_train, X_test, y_train, y_test = train_test_split(iris_dataset['data'], iris_dataset['target'], random_state = 0)
# the results after splitting the data
print(X_train.shape)
print(y_train.shape)
print(X_test.shape)
print(y_test.shape)


# --- look at the Data ---

iris_dataframe = pd.DataFrame(X_train, columns=iris_dataset.feature_names)
pd.plotting.scatter_matrix(iris_dataframe, c=y_train, figsize=(15, 15), marker = 'o', hist_kwds = {'bins': 20}, s=60, alpha= .8, cmap = mglearn.cm3)