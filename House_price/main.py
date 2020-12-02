import os
import tarfile
import urllib
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.model_selection import StratifiedShuffleSplit
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OrdinalEncoder
from sklearn.preprocessing import OneHotEncoder
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from sklearn.tree import DecisionTreeRegressor
from sklearn.model_selection import cross_val_score
from zlib import crc32
from pandas.plotting import scatter_matrix

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

#if data set not too large, use standard corelation coefficient, using corr() fct
corr_matrix = housing.corr()

#look how each attribute correlates with the median house value (add print to see the values)
corr_matrix["median_house_value"].sort_values(ascending=False)

#--------------------------Preparing the data for Machine Learning Algorithms--------------------------

housing = strat_train_set.drop("median_house_value", axis=1)
house_labels = strat_train_set["median_house_value"].copy()

#--------------------------Data Cleaning--------------------------

#1. Get rid of the corresponding districts.
#housing.dropna(subset=["total_bedrooms"])
#2. Get rid of the whole attribute.
#housing.drop("total_bedrooms", axis=1)
#3. Set the values to some value (zero, the mean, the median, etc.).
median = housing["total_bedrooms"].median()
housing["total_bedrooms"].fillna(median, inplace=True)

#we can use a Scikit-Learn fct to fill in the missing values

imputer = SimpleImputer(strategy = "median")
housing_num = housing.drop("ocean_proximity", axis = 1) #copy of the data without string value
imputer.fit(housing_num)

X = imputer.transform(housing_num) #rez = plain numpy array containing transformed features
housing_tr = pd.DataFrame(X, columns = housing_num.columns, index = housing_num.index)

#--------------------------Handling Text and Categorical Attributes--------------------------

#convert text based categories from text to numbers
housing_cat = housing[["ocean_proximity"]]
ordinal_encoder = OrdinalEncoder()
housing_cat_encoded = ordinal_encoder.fit_transform(housing_cat)

#hot-one encoding
cat_encoder = OneHotEncoder()
housing_cat_1hot = cat_encoder.fit_transform(housing_cat)
housing_cat_1hot.toarray()

#--------------------------Custom Transformers--------------------------

#used for tasks like cleanup operations, combining attributes
rooms_ix, bedrooms_ix, population_ix, households_ix = 3, 4, 5, 6
class CombinedAttributesAdder(BaseEstimator, TransformerMixin):
    def __init__(self, add_bedrooms_per_room = True): # no *args or **kargs
        self.add_bedrooms_per_room = add_bedrooms_per_room

    def fit(self, X, y=None):
        return self # nothing else to do

    def transform(self, X):
        rooms_per_household = X[:, rooms_ix] / X[:, households_ix]
        population_per_household = X[:, population_ix] / X[:, households_ix]
        if self.add_bedrooms_per_room:
            bedrooms_per_room = X[:, bedrooms_ix] / X[:, rooms_ix]
            return np.c_[X, rooms_per_household, population_per_household,bedrooms_per_room]
        else:
            return np.c_[X, rooms_per_household, population_per_household]

#attr_adder = CombinedAttributesAdder(add_bedrroms_per_room = False)
#housing_extra_attribs = attr_adder.transform(housing.values)

#--------------------------Feature Scaling--------------------------

# use min-max scaling and standardization to get all attributes to have the same scale

#--------------------------Transformation Pipelines--------------------------

num_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy = "median")),
    ('attribs_adder', CombinedAttributesAdder()),
    ('std_scaler', StandardScaler())])
housing_num_tr = num_pipeline.fit_transform(housing_num)

num_attribs = list(housing_num)
cat_attribs = ["ocean_proximity"]
full_pipeline = ColumnTransformer([
("num", num_pipeline, num_attribs),
("cat", OneHotEncoder(), cat_attribs),
])
housing_prepared = full_pipeline.fit_transform(housing)

#--------------------------Select and Train a Model--------------------------
#make a linear regression model
lin_reg = LinearRegression()
lin_reg.fit(housing_prepared, house_labels)

some_data = housing.iloc[:5]
some_labels = house_labels.iloc[:5]
some_data_prepared = full_pipeline.transform(some_data)
print("Predictions: " + str(lin_reg.predict(some_data_prepared)))
print("Labels: " + str(list(some_labels)))

#we test the accuracy of the trained data by using mean_squared_error()
housing_prediction = lin_reg.predict(housing_prepared)
lin_mse = mean_squared_error(house_labels, housing_prediction)
lin_rmse = np.sqrt(lin_mse)
print(lin_rmse)

#train a Decision Tree Regression
tree_reg = DecisionTreeRegressor()
tree_reg.fit(housing_prepared, house_labels)
housing_predictions = tree_reg.predict(housing_prepared)
tree_mse = mean_squared_error(house_labels, housing_prediction)
tree_rmse = np.sqrt(tree_mse)
print(tree_rmse)

#--------------------------Better Evaluation Using Cross-Validation--------------------------

# use the train_test_split() or cross_val_score() function
scores = cross_val_score(tree_reg, housing_prepared, house_labels, scoring="neg_mean_squared_error", cv=10)
tree_rmse_scores = np.sqrt(-scores)

#see results
def display_scores(scores):
    print("Scores: " + str(scores))
    print("Mean: " + str(scores.mean()))
    print("Standard deviation: " + str(scores.std()) + "\n")

display_scores(tree_rmse_scores)

#can save every model that you trained using joblib => ex: joblib.dump(my_model, "my_model.pkl")
