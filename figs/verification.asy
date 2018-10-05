string method = "OLS";

settings.outformat = "pdf";
settings.prc = false;
settings.render = 4;
size(15cm,10cm,IgnoreAspect);
import three;
import graph3;
usepackage("mathpazo");

triple view = (1,4,1);
currentprojection=orthographic(view,up=Z);
currentlight=light(view);
real myopacity=0.6;

real[] x1 = input("data/verification_x1.dat").line().csv();
real[] x2 = input("data/verification_x2.dat").line().csv();
real[] y_exact = input("data/verification_y_exact.dat").line().csv();
real[] y = input("data/verification_y_" + method + ".dat").line().csv();

int m = x1.length;
int n = x2.length;

triple exact(pair ij){
    int i = (int) round(ij.x);
    int j = (int) round(ij.y);
    return (x1[i], x2[j], y_exact[i*n+j]);
}

triple approx(pair ij){
    int i = (int) round(ij.x);
    int j = (int) round(ij.y);
    return (x1[i], x2[j], y[i*n+j]);
}

write(m, n);
write(x1);
write(x2);
write(y);

surface graf = surface(exact, (0,0), (m-1,n-1),nu=m,nv=n,Spline);
draw(graf,surfacepen=material(blue+0.2*white+opacity(myopacity)));
surface graf = surface(approx, (0,0), (m-1,n-1),nu=m,nv=n,Spline);
draw(graf,surfacepen=material(red+0.2*white+opacity(myopacity)));
//axes3("$x_1$","$x_2$","$y$",min=(-0.2,-0.2,-0.2),max=(1.2,1.2,1.2),arrow=Arrow3());
