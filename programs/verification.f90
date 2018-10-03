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

    integer :: d, N, num_bootstraps, i, u_bias_variance, u_y, u_mse_r2
    real(dp) :: test_fraction, lambda, sigma, mse, r2

    real(dp), allocatable :: x(:,:), y(:), y_prediction(:)
    d = 5
    N = 1000000
    sigma = 0.1
    lambda = 0.1
    num_bootstraps = 100

    call create_basis(basis, d)
    fitters = [regressor_container(ols(basis)), &
               regressor_container(ridge(lambda, basis)), &
               regressor_container(lasso(lambda, basis))]

    open(newunit=u_bias_variance, file="data/verification_bias_variance.dat", &
         status = "replace")
    write(u_bias_variance, "(a)") "Method MSE Bias Variance"
    open(newunit=u_mse_r2, file="data/verification_mse_r2.dat", status="replace")
    write(u_mse_r2, "(a)") "Method MSE R2"

    allocate(y_prediction(N))

    do i = 1, 3
        fitter = fitters(i)%element
        x = random_meshgrid(nint(sqrt(1.0d0*N)), "data/verification_" // fitter%method)
        y = franke(x)
        call add_noise(y, sigma)

        call fitter%fit(x, y)
        call fitter%predict(x, y_prediction, y, mse, r2)
        write(u_mse_r2, "(a,x,f0.4,x,f0.3)") fitter%method, mse, r2
    end do
    close(u_mse_r2)
    close(u_bias_variance)
end program
