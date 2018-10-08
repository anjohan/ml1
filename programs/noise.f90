program noise
    use iso_fortran_env, only: dp => real64
    use mod_utilities
    use mod_polynomials2d
    use mod_bootstrap
    use mod_ols
    use mod_ridge
    implicit none

    real(dp), allocatable :: x(:,:), x_test(:,:), y(:), y_test(:), sigma(:), y_pred(:), &
                             R2(:), R2_test(:), y0(:), y0_test(:)
    real(dp) :: lambda, mse
    integer :: N, d, i, u, num_sigma

    class(regressor), allocatable :: fitter
    class(polynomial2d), allocatable :: basis(:)

    N = 400

    d = 5
    num_sigma = 21
    call create_basis(basis, d)

    x = random_meshgrid(nint(sqrt(1.0d0*N)))
    x_test = random_meshgrid(nint(sqrt(1.0d0*N)))
    y0 = franke(x)
    y0_test = franke(x_test)

    sigma = [(i*1.0d0/(num_sigma-1), i = 0, num_sigma-1)]

    lambda = 0.001d0
    fitter = ridge(lambda, basis)
    allocate(y_pred(N))
    allocate(R2(num_sigma), R2_test(num_sigma))

    do i = 1, size(sigma)
        y = y0
        y_test = y0_test

        call add_noise(y, sigma(i))
        call add_noise(y_test, sigma(i))

        call fitter%fit(x, y)
        call fitter%predict(x, y_pred, y, mse, R2(i))
        call fitter%predict(x_test, y_pred, y_test, mse, R2_test(i))
    end do

    open(newunit=u, file="data/noise.dat", status="replace")
    write(u, "(f0.6,x,f0.6,x,f0.6)") (sigma(i), R2(i), R2_test(i), i = 1, num_sigma)
    close(u)
end program
