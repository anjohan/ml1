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

    integer :: d, N, num_bootstraps, i
    real(dp) :: test_fraction, lambda, sigma

    real(dp), allocatable :: x(:,:), y(:)
    d = 5
    N = 1000000
    sigma = 0.1
    lambda = 0.1
    num_bootstraps = 100

    call create_basis(basis, d)
    fitters = [regressor_container(ols(basis)), &
               regressor_container(ridge(lambda, basis)), &
               regressor_container(lasso(lambda, basis))]

    do i = 1, 3
        fitter = fitters(i)%element
        x = random_meshgrid(nint(sqrt(1.0d0*N)), "data/verification_" // fitter%method)
        y = franke(x)
        call add_noise(y, sigma)
    end do
end program
