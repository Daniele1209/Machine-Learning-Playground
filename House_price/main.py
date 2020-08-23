import os
import tarfile
import urllib
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.model_selection import StratifiedShuffleSplit
from zlib import crc32

#fetch the data from the github repo

DOWNLOAD_ROOT = "https://raw.githubusercontent.com/ageron/handson-ml2/master/"
HOUSING_PATH = os.path.join("datasets", "housing")
HOUSING_URL = DOWNLOAD_ROOT + "datasets/housing/housing.tgz"

def fetch_housing_data(housing_url  = HOUSING_URL, housing_path = HOUSING_PATH):
    os.makedirs(housing_path, exist_ok = True)
    tgz_path = os.path.join(housing_path, "housing.tgz")
    urllib.request.urlretrieve(housing_url, tgz_path)
    housing_tgz = tarfile.open(tgz_path)
    housing_tgz.extractall(path = housing_path)
    housing_tgz.close()

#load the data using pandas

def load_housing_data(housing_path = HOUSING_PATH):
    csv_path = os.path.join(housing_path, "housing.csv")
    return pd.read_csv(csv_path)

fetch_housing_data()
housing = load_housing_data()
housing.head()


housing.hist(bins = 50, figsize = (20, 15))
plt.show()

#-------------------------------split the data randomly---------------------------------

#splitting the training set so we can test the accuracy of the predictions later on

#variant 1
def split_train_test(data, test_ratio):
    shuffled_indices = np.random.permutation(len(data))
    test_set_size = int(len(data) * test_ratio)
    test_indices = shuffled_indices[:test_set_size]
    train_indices = shuffled_indices[test_set_size:]
    return data.iloc[train_indices], data.iloc[test_indices]

#variant 2
def var_2():
    train_set, test_set = split_train_test(housing, 0.2)

#variant 1 and variant 2 can be used once, but they will break the next time we fetch an updated data set

#variant 3
def test_set_check(identifier, test_ratio):
    return(np.int64(identifier)) & 0xffffffff < test_ratio * 2**32

#variant 4
def split_train_test_by_id(data, test_ratio, id_column):
    ids = data[id_column]
    in_test_set = ids.apply(lambda id_: test_set_check(id_, test_ratio))
    return data.loc[~in_test_set], data.loc[in_test_set]

#variant 3 and variant 4 will remain at a ratio of 20% of data, even if the dataset is updated

#we will use variant 4 bcz it suits our dataset better
def using_var_4():
    housing_with_id = housing.reset_index()   #adds one more column, called "index"
    train_set, test_set = split_train_test_by_id(housing_with_id, 0.2, "index")

#you can also build an ID by playing around with the parameters of the database like so:
def using_build_id():
    housing_with_id = housing.reset_index()
    housing_with_id["id"] = housing["longitude"] * 1000 + housing["latitude"]
    train_set, test_set = split_train_test_by_id(housing_with_id, 0.2, "id")

#or use the sklearn library
def using_sklearn():
    train_set, test_set = train_test_split(housing, test_size = 0.2, random_state = 42)

#----------------------------split the data using stratified sampling-------------------------------

def using_stratified_sampling():
    housing["income_cat"] = pd.cut(housing["median_income"],
                                   bins = [0., 1.5, 3.0, 4.5, 6., np.inf],
                                   labels = [1, 2, 3, 4, 5])
    housing["income_cat"].hist()
    plt.show()

    split = StratifiedShuffleSplit(n_splits=1, test_size=0.2, random_state=42)
    for train_index, test_index in split.split(housing, housing["income_cat"]):
        strat_train_set = housing.loc[train_index]
        strat_test_set = housing.loc[test_index]
        print(strat_test_set["income_cat"].value_counts() / len(strat_test_set))

    #remove "income_cat" so the data goes back to normal
    for set_ in (strat_train_set, strat_test_set):
        set_.drop("income_cat", axis=1, inplace=True)

#------------------------------------visualizing the data----------------------------------------

housing.plot(kind="scatter", x="longitude", y="latitude")
#adding alpha = 0.1 makes it easier to visualize places of high density
housing.plot(kind="scatter", x="longitude", y="latitude", alpha=0.1)
plt.show()

#get a more informative colored map
housing.plot(kind="scatter", x="longitude", y="latitude", alpha=0.4,
             s=housing["population"]/100, label="population", figsize=(10,7),
             c="median_house_value", cmap=plt.get_cmap("jet"), colorbar=True)
plt.show()

#-------------------------------looking for correlations----------------------------

