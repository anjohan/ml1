program verification
    use iso_fortran_env, only: dp => real64
    use mod_utilities
    use mod_polynomials2d
    use mod_ols
    use mod_ridge
    use mod_lasso
    use mod_bootstrap
    implicit none

    class(regressor_container), allocatable :: fitters(:)
    class(polynomial2d), allocatable :: basis(:)
    class(bootstrapper), allocatable :: bs
    class(regressor), allocatable :: fitter

    integer :: d, p, N, num_bootstraps, i, j, u_bias_variance, u_tmp, u_mse_r2
    real(dp) :: test_fraction, lambda, sigma, mse, r2
    character(len=:), allocatable :: method, outfile

    real(dp), allocatable :: x(:,:), y(:), y_prediction(:), &
                             x_test(:,:), y_test(:), y_test_prediction(:)
    d = 5
    N = 2500
    sigma = 0.05
    lambda = 0.001
    num_bootstraps = 100
    test_fraction = 0.2

    call create_basis(basis, d)
    p = size(basis)
    fitters = [regressor_container(ols(basis)), &
               regressor_container(ridge(lambda, basis)), &
               regressor_container(lasso(lambda, basis))]

    open(newunit=u_bias_variance, file="data/verification_bias_variance.dat", &
         status = "replace")
    write(u_bias_variance, "(a)") "Method MSE Bias+Variance Bias Variance"
    open(newunit=u_mse_r2, file="data/verification_mse_r2.dat", status="replace")
    write(u_mse_r2,*) "Method {MSE (train)} {$R^2$ (train)} {MSE (test)} {$R^2$ (test)}"

    allocate(y_prediction(N),x(N,2), y(N))
    x(:,:) = random_meshgrid(nint(sqrt(1.0d0*N)), "data/verification")
    y(:) = franke(x)
    call add_noise(y, sigma)

    allocate(y_test_prediction(N),x_test(N,2), y_test(N))
    x_test(:,:) = random_meshgrid(nint(sqrt(1.0d0*N)), "data/verification")
    y_test(:) = franke(x_test)
    call add_noise(y_test, sigma)

    open(newunit=u_tmp, file="data/verification_y_exact.dat", status="replace")
    write(u_tmp, "(*(f0.6,:,','))") y
    close(u_tmp)

    do i = 3, 1, -1
        fitter = fitters(i)%element
        method = fitter%method
        write(*,*) method

        call fitter%fit(x, y)
        call fitter%predict(x, y_prediction, y, mse, r2)
        write(u_mse_r2, "(a,x,f0.6,x,f0.6,x)", advance="no") method, mse, r2
        call fitter%fit(x_test, y_test)
        call fitter%predict(x, y_test_prediction, y_test, mse, r2)
        write(u_mse_r2, "(f0.6,x,f0.6)") mse, r2

        write(*,*) method
        outfile = "data/verification_y_" // method // ".dat"

        open(newunit=u_tmp, file=outfile, status="replace")
        write(u_tmp, "(*(f0.6,:,','))") y_prediction
        close(u_tmp)

        open(newunit=u_tmp, file="data/verification_beta_" // method // ".dat", &
             status="replace")
        write(u_tmp, "(*(f0.6,:,','))") fitter%beta
        close(u_tmp)

        bs = bootstrapper(fitter)
        call bs%bootstrap(x, y, num_bootstraps, test_fraction)

        write(u_bias_variance, "(a,x,*(f0.6,:,x))") fitter%method, bs%mean_MSE, &
                                                    bs%bias+bs%variance, bs%bias, &
                                                    bs%variance

        open(newunit=u_tmp, file="data/verification_mean_beta_" // fitter%method // ".dat", &
             status="replace")
        write(u_tmp,*) "index beta uncertainty"
        do j = 1, p
            write(u_tmp,*) j, bs%mean_beta(j), 2*sqrt(bs%beta_variance(j))
        end do
        close(u_tmp)
    end do

    close(u_mse_r2)
    close(u_bias_variance)
end program
