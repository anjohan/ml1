program geography
    use iso_fortran_env, only: dp => real64
    use mod_utilities
    use mod_polynomials2d
    use mod_ols
    use mod_ridge
    use mod_bootstrap
    implicit none

    class(regressor), allocatable :: fitter
    class(bootstrapper), allocatable :: bs
    class(polynomial2d), allocatable :: basis(:)

    integer :: m, n, d, num_lambda, idx, i, j, best_lambda_index, &
               num_bootstraps, u
    real(dp), allocatable :: x(:,:), y(:), lambda(:), best_beta(:), y_reshaped(:,:)
    real(dp) :: dx1, dx2, test_fraction, best_mse, ridge_mse, ridge_bias, ridge_variance

    num_lambda = 11
    lambda = [(10**(-5+i*6.0d0/(num_lambda-1)), i = 0, num_lambda-1)]

    read(*,*) m, n
    dx1 = 1.0d0/(m-1)
    dx2 = 1.0d0/(n-1)
    allocate(x(m*n,2), y(m*n))
    read(*,*) y

    num_bootstraps = 100
    test_fraction = 0.2

    idx = 0
    do j = 0, n-1
        do i = 0, m-1
            idx = idx + 1
            x(idx,1) = i*dx1
            x(idx,2) = j*dx2
        end do
    end do

    open(newunit=u, file="data/geography_mse.dat", status="replace")
    write(u, *) "{$d$} {MSE (OLS)} {Bias (OLS)} {Variance (OLS)} " &
                // "{MSE (Ridge)} {Bias (Ridge)} {Variance (Ridge)} {lambda}"

    best_mse = huge(1.0d0)

    do d = 1, 6
        write(*,*) "d = ", d
        call create_basis(basis, d)

        fitter = ols(basis)
        bs = bootstrapper(fitter)
        call bs%bootstrap(x, y, num_bootstraps, test_fraction)

        write(u, fmt="(i0,3(x,f0.8))", advance="no") d, bs%mean_MSE, &
                                                                bs%bias, bs%variance
        if (bs%mean_MSE < best_mse) then
            best_mse = bs%mean_MSE
            best_beta = bs%mean_beta
        end if

        ridge_mse = huge(1.0d0)

        do i = 1, num_lambda
            fitter = ridge(lambda(i), basis)
            bs = bootstrapper(fitter)
            call bs%bootstrap(x, y, num_bootstraps, test_fraction)

!            write(u, fmt="(i0,x,f0.8,x,f0.8,x,f0.8)") d, bs%mean_MSE, &
!                                                      bs%bias, bs%variance
            if (bs%mean_MSE < best_mse) then
                best_mse = bs%mean_MSE
                best_beta = bs%mean_beta
            end if

            if (bs%mean_MSE < ridge_mse) then
                ridge_mse = bs%mean_MSE
                ridge_bias = bs%bias
                ridge_variance = bs%variance
                best_lambda_index = i
            end if
            deallocate(fitter, bs)
        end do
        write(u, fmt="(4(x,f0.8))") ridge_mse, ridge_bias, ridge_variance,&
                                    lambda(best_lambda_index)
    end do
    close(u)

    open(newunit=u, file="data/geography_beta.dat", status="replace")
    write(u, "(*(f0.6,:,','))") best_beta
    close(u)

end program
