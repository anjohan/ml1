program complexity
    use iso_fortran_env, only: dp => real64
    use mod_utilities
    use mod_basis
    use mod_polynomials2d
    use mod_ridge
    use mod_ols
    use mod_bootstrap
    implicit none

    class(bootstrapper), allocatable :: bs
    class(regressor), allocatable :: fitter
    class(polynomial2d), allocatable :: basis(:)

    integer :: N, num_bootstraps, i, u
    integer, allocatable :: d(:)

    real(dp) :: sigma, lambda, test_fraction
    real(dp), allocatable :: x(:,:), y(:)

    N = 90000
    num_bootstraps = 1000
    sigma = 0.3d0
    lambda = 0.001d0
    test_fraction = 0.4

    d = [(i, i = 0, 5)]

    x = random_meshgrid(nint(sqrt(1.0d0*N)))
    y = 3*x(:,1)**2*x(:,2) + 2 + x(:,1)*x(:,2)**3 + x(:,1)**10*x(:,2)**4
    !y = franke(x)
    call add_noise(y, sigma)

    open(newunit=u, file="data/complexity.dat", status="replace")
    write(u, *) "d mse(ols) bias(ols) var(ols) mse(ridge) bias(ridge) var(ridge)"

    do i = 1, size(d)
        write(*,*) "d = ", d(i)

        call create_basis(basis, d(i))
        fitter = ols(basis)
        bs = bootstrapper(fitter)
        call bs%bootstrap(x, y, num_bootstraps, test_fraction)

        write(u, fmt="(i0,*(:,x,f0.8))", advance="no") d(i), bs%mean_MSE, bs%bias, bs%variance

        fitter = ridge(lambda, basis)
        bs = bootstrapper(fitter)
        call bs%bootstrap(x, y, num_bootstraps, test_fraction)

        write(u, fmt="(*(:,x,f0.8))") bs%mean_MSE, bs%bias, bs%variance
    end do
end program
