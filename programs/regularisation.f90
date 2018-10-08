program regularisation
    use iso_fortran_env, only: dp => real64
    use mod_utilities
    use mod_polynomials2d
    use mod_ridge
    use mod_bootstrap
    implicit none

    class(bootstrapper), allocatable :: bs
    class(ridge), allocatable :: fitter
    class(polynomial2d), allocatable :: basis(:)

    integer :: N, d, num_lambda, num_bootstraps, p, i, u_r2, u_beta, u_bivar, j
    real(dp) :: sigma, R2, R2_test, mse, test_fraction
    real(dp), allocatable :: x(:,:), y(:), x_test(:,:), y_test(:), y_pred(:), &
                             lambda(:)

    num_lambda = 21
    num_bootstraps = 1000
    N = 400
    d = 7
    sigma = 0.20
    test_fraction = 0.4
    x = random_meshgrid(nint(sqrt(1.0d0*N)))
    y = franke(x)
    call add_noise(y, sigma)
    x_test = random_meshgrid(nint(sqrt(1.0d0*N)))
    y_test = franke(x_test)
    call add_noise(y_test, sigma)

    lambda = [(10**(-8+i*8.0d0/(num_lambda-1)), i = 0, num_lambda-1)]

    call create_basis(basis, d)
    p = size(basis)

    allocate(y_pred(N))

    open(newunit=u_r2, file="data/r2_lambda.dat", status="replace")
    write(u_r2, *) "lambda R2(train) R2(test)"

    open(newunit=u_bivar, file="data/bivar_lambda.dat", status="replace")
    write(u_bivar, *) "lambda mse bias variance"

    open(newunit=u_beta, file="data/beta_lambda.dat", status="replace")
    write(u_beta, *) "lambda beta_i beta_i_variance"

    do i = 1, num_lambda
        fitter = ridge(lambda(i), basis)
        call fitter%fit(x, y)
        call fitter%predict(x, y_pred, y, mse, R2)
        call fitter%predict(x_test, y_pred, y_test, mse, R2_test)

        write(u_r2, *) lambda(i), R2, R2_test

        bs = bootstrapper(fitter)
        call bs%bootstrap(x, y, num_bootstraps, test_fraction)

        write(u_bivar, *) lambda(i), bs%mean_MSE, bs%bias, bs%variance

        write(u_beta, "(*(f0.10,:,x))") lambda(i), (bs%mean_beta(j), bs%beta_variance(j), j=1,p)
    end do
    close(u_r2)
    close(u_bivar)
    close(u_beta)

end program
