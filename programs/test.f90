program test
    use iso_fortran_env, only: dp => real64
    use mod_utilities
    use mod_polynomials2d
    use mod_ols
    use mod_ridge
    use mod_lasso
    use mod_bootstrap
    implicit none

    class(regressor), allocatable :: fitter
    class(bootstrapper), allocatable :: bs
    class(polynomial2d), allocatable :: basis(:)
    integer :: d = 1, N = 1000000, i
    real(dp), allocatable :: x(:,:), y(:), y_pred(:), beta(:), mean_beta(:)
    real(dp) :: mse, r2

    allocate(x(N,2), y(N), y_pred(N))

    x = random_meshgrid(nint(sqrt(1.0*N)), "test")

    y = 1 - 2*x(:,1) + 0*x(:,1)**2 + 3.5*x(:,2) + 4*x(:,1)*x(:,2) + 5*x(:,2)**2
    call add_noise(y, sigma=0.5d0)

    call create_basis(basis, d)
    ! fitter = ols(basis=basis)
    fitter = ridge(basis=basis, lambda=1.0_dp)
    ! fitter = lasso(basis=basis, lambda=1.5_dp)

    call fitter%fit(x, y)
    beta = fitter%beta

    write(*,*) fitter%beta

    call fitter%predict(x, y_pred, y, mse, r2)
    ! write(*,*) y
    ! write(*,*) y_pred
    write(*,*) mse, r2

    bs = bootstrapper(fitter)
    call bs%bootstrap(x, y, 100, 0.4d0)
    write(*,*) bs%mean_beta
    write(*,*) bs%mean_MSE, bs%final_R2
    mean_beta = bs%mean_beta
    write(*,*) bs%mean_MSE, bs%bias+bs%variance, bs%bias, bs%variance

    x = random_meshgrid(nint(sqrt(1.0*N)), "test")

    y = 1 - 2*x(:,1) + 0*x(:,1)**2 + 3.5*x(:,2) + 4*x(:,1)*x(:,2) + 5*x(:,2)**2 + 5*sin(x(:,1)*x(:,2))
    call add_noise(y, sigma=0.5d0)

    fitter%beta = beta
    call fitter%predict(x, y_pred, y, mse, r2)
    write(*,*) mse, r2

    fitter%beta = mean_beta
    call fitter%predict(x, y_pred, y, mse, r2)
    write(*,*) mse, r2

    ! write(*, "(*(f10.6,f10.6,f10.6,:,/))") (x(i,1:2), y(i), i = 1, N)
    ! call shuffle(x, y)
    ! write(*,*)
    ! write(*, "(*(f10.6,f10.6,f10.6,:,/))") (x(i,1:2), y(i), i = 1, N)

end program
