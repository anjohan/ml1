import numpy as np
from tqdm import tqdm
from sklearn.linear_model import Lasso
from sklearn.metrics import mean_squared_error, r2_score

N = 10000
d = 5
sigma = 0.05
alpha = 0.001
num_bootstraps = 200

test_fraction = 0.5

x1, x2 = np.random.rand(2, int(round(np.sqrt(N))))
x1, x2 = np.meshgrid(x1, x2)
x1 = x1.reshape((N, 1))
x2 = x2.reshape((N, 1))

y = 0.75*np.exp(-(0.25*(9*x1-2)**2) - 0.25*((9*x2-2)**2)) \
  + 0.75*np.exp(-((9*x1+1)**2)/49.0 - 0.1*(9*x2+1)) \
  + 0.50*np.exp(-(9*x1-7)**2/4.0 - 0.25*((9*x2-3)**2)) \
  - 0.20*np.exp(-(9*x1-4)**2 - (9*x2-7)**2)

regressor = Lasso(alpha=alpha, fit_intercept=False)

X = np.column_stack(
    (x1**i * x2**j for j in range(d + 1) for i in range(d - j + 1)))
p = X.shape[1]

N_test = int(round(test_fraction * N))
N_train = N - N_test
y_train = y[N_test:]
X_train = X[N_test:, :]

betas = np.zeros((p, num_bootstraps))

for i in tqdm(range(num_bootstraps)):
    indices = np.random.randint(0, N_train, N_train)
    X_selection = X_train[indices, :]
    y_selection = y_train[indices, :]
    regressor.fit(X_selection, y_selection)
    betas[:, i] = regressor.coef_

mean_beta = np.sum(betas, axis=1) / num_bootstraps
beta_variances = np.var(betas, axis=1)

np.savetxt(
    "data/verification_mean_beta_sklearn.dat",
    np.column_stack((np.arange(p) + 1, mean_beta, beta_variances)),
    header="index beta uncertainty",
    comments="")
