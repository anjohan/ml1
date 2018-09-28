program test
    use iso_fortran_env, only: dp => real64
    use mod_ridge2d
    implicit none

    class(polyfitter2d), allocatable :: pf
    integer :: d = 2, N = 10
    real(dp), allocatable :: x(:,:), y(:), y_pred(:)
    real(dp) :: mse, r2

    allocate(x(N,2), y(N), y_pred(N))

    call random_number(x)

    y = 1 + 2*x(:,1) + 3*x(:,1)**2 + 3.5*x(:,2) + 4*x(:,1)*x(:,2) + 5*x(:,2)**2

    pf = ridge2d(d, 0.1_dp)

    call pf%fit(x, y)

    write(*,*) pf%beta

    call pf%predict(x, y_pred, y, mse, r2)
    write(*,*) y
    write(*,*) y_pred
    write(*,*) mse, r2
end program
