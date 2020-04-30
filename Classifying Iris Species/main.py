import pandas as pd
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
import mglearn
import matplotlib.pyplot as plt
import numpy as np
from sklearn.neighbors import KNeighborsClassifier

# --- basic stuff ---

# we load the Bunch object from sklearn.datasets
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
plt.show()


# --- k - nearest neighbors - build a machine learning model ---

knn = KNeighborsClassifier(n_neighbors = 1)
# call the fit method of the knn object
knn.fit(X_train, y_train)


# --- make predictions ---

X_new = np.array([[5, 2.9, 1, 0.2]]) # data about a random iris that we assume we found
print(X_new.shape)

prediction = knn.predict(X_new)
print(prediction) # <- this will be the prediction it came up with
print(iris_dataset['target_names'][prediction]) # and this is the name


# --- model evaluation ---

y_pred = knn.predict(X_test)
print(y_pred)

print("Score test: {:.2f}".format(knn.score(X_test, y_test))) # this is the accuracy test result


# INTRODUCTION PROJECT DONE :)
# - Mos Daniele

