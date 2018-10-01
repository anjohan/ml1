program test
    use iso_fortran_env, only: dp => real64
    use mod_polynomials2d
    use mod_ols
    use mod_ridge
    use mod_lasso
    use mod_bootstrap
    implicit none

    class(regressor), allocatable :: fitter
    class(bootstrapper), allocatable :: bs
    class(polynomial2d), allocatable :: basis(:)
    integer :: d = 2, N = 10000
    real(dp), allocatable :: x(:,:), y(:), y_pred(:)
    real(dp) :: mse, r2

    allocate(x(N,2), y(N), y_pred(N))

    call create_basis(basis,d)

    call random_number(x)

    y = 1 - 2*x(:,1) + 0*x(:,1)**2 + 3.5*x(:,2) + 4*x(:,1)*x(:,2) + 5*x(:,2)**2

    ! fitter = ols(basis=basis)
    ! fitter = ridge(basis=basis, lambda=1.0_dp)
    fitter = lasso(basis=basis, lambda=1.5_dp)

    call fitter%fit(x, y)

    write(*,*) fitter%beta

    call fitter%predict(x, y_pred, y, mse, r2)
    ! write(*,*) y
    ! write(*,*) y_pred
    write(*,*) mse, r2

    bs = bootstrapper(fitter)
    call bs%bootstrap(x, y, 1000)
    write(*,*) sum(bs%betas, dim=2)/size(bs%betas, dim=2)
end program
