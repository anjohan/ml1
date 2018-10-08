import numpy as np
from tqdm import tqdm
from sklearn.linear_model import Lasso
from sklearn.metrics import mean_squared_error, r2_score


def franke(x1, x2):
    y = 0.75*np.exp(-(0.25*(9*x1-2)**2) - 0.25*((9*x2-2)**2)) \
      + 0.75*np.exp(-((9*x1+1)**2)/49.0 - 0.1*(9*x2+1)) \
      + 0.50*np.exp(-(9*x1-7)**2/4.0 - 0.25*((9*x2-3)**2)) \
      - 0.20*np.exp(-(9*x1-4)**2 - (9*x2-7)**2)
    return y


def random_meshgrid(N):
    x1, x2 = np.random.rand(2, int(round(np.sqrt(N))))
    x1, x2 = np.meshgrid(x1, x2)
    x1 = x1.reshape((N, 1))
    x2 = x2.reshape((N, 1))
    return x1, x2


def create_X(x1, x2, d):
    X = np.column_stack(
        (x1**i * x2**j for j in range(d + 1) for i in range(d - j + 1)))
    return X


N = 10000
d = 5
sigma = 0.1
alpha = 0.000001
num_bootstraps = 1000
test_fraction = 0.4

x1, x2 = random_meshgrid(N)
X = create_X(x1, x2, d)
y = franke(x1, x2) + sigma * np.random.normal(size=(N, 1))

x1_test, x2_test = random_meshgrid(N)
X_test = create_X(x1_test, x2_test, d)
y_test = franke(x1_test, x2_test) + sigma * np.random.normal(size=(N, 1))

regressor = Lasso(alpha=alpha, fit_intercept=False)
y_pred = regressor.fit(X, y).predict(X)
MSE_train = mean_squared_error(y_pred, y)
R2_train = r2_score(y, y_pred)

y_pred = regressor.fit(X, y).predict(X_test)
MSE_test = mean_squared_error(y_pred, y_test)
R2_test = r2_score(y_test, y_pred)

with open("data/verification_mse_r2_lasso.dat", "w") as outfile:
    outfile.write(
        "LASSO %g %g %g %g" % (MSE_train, R2_train, MSE_test, R2_test))

p = X.shape[1]

N_test = int(round(test_fraction * N))
N_train = N - N_test
y_test = y[:N_test]
X_test = X[:N_test, :]
y_train = y[N_test:]
X_train = X[N_test:, :]

betas = np.zeros((p, num_bootstraps))
MSEs = np.zeros(num_bootstraps)
predictions = np.zeros((N_test, num_bootstraps))

for i in tqdm(range(num_bootstraps)):
    indices = np.random.randint(0, N_train, N_train)
    X_selection = X_train[indices, :]
    y_selection = y_train[indices, :]
    regressor.fit(X_selection, y_selection)
    betas[:, i] = regressor.coef_
    predictions[:, i] = regressor.predict(X_test)
    MSEs[i] = mean_squared_error(y_test, predictions[:, i])

mean_beta = np.sum(betas, axis=1) / num_bootstraps
beta_variances = np.var(betas, axis=1)
mean_MSE = np.mean(MSEs)
bias = np.mean((y_test - np.mean(predictions, axis=1, keepdims=True))**2)
variance = np.mean((predictions - np.mean(predictions, axis=1, keepdims=True))
                   **2)
with open("data/verification_bias_variance_lasso.dat", "w") as outfile:
    outfile.write("LASSO %.6f %.6f %.6f %.6f" % (mean_MSE, bias + variance,
                                                 bias, variance))

np.savetxt(
    "data/verification_mean_beta_sklearn.dat",
    np.column_stack((np.arange(p) + 1, mean_beta,
                     2 * np.sqrt(beta_variances))),
    header="index beta uncertainty",
    comments="")
