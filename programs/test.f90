program test
    use iso_fortran_env, only: dp => real64
    use mod_polyfitter2d
    implicit none

    class(polyfitter2d), allocatable :: pf
    integer :: d = 2, N = 10
    real(dp), allocatable :: x(:,:), y(:)

    allocate(x(N,2), y(N))

    call random_number(x)

    y = 1 + 2*x(:,1) + 3*x(:,1)**2 + 3.5*x(:,2) + 4*x(:,1)*x(:,2) + 5*x(:,2)**2

    pf = polyfitter2d(d)

    call pf%fit(x, y)

    write(*,*) pf%beta
end program
