//string method = "OLS";

settings.outformat = "pdf";
settings.prc = false;
settings.render = 16;
size(12cm,8cm,IgnoreAspect);
import three;
import graph3;
import palette;
usepackage("mathpazo");

triple view = (1,4,1);
currentprojection=orthographic(view,up=Z);
currentlight=light(view);
real myopacity=0.6;

real[] x1 = input("data/verification_x1.dat").line().csv();
real[] x2 = input("data/verification_x2.dat").line().csv();
real[] y_exact = input("data/verification_y_exact.dat").line().csv();
real[] beta = input("data/verification_beta_" + method + ".dat").line().csv();

int m = x1.length;
int n = x2.length;
int p = beta.length;
int d = (int) round((-3+sqrt(9+8*(p-1)))/2);

real gauss(real r, real px, real x, real x0, real sx, real py, real y, real y0, real sy){
    return r*exp(-(px*x-x0)*(px*x-x0)/sx - (py*y-y0)*(py*y-y0)/sy);
}

real franke(real x, real y){
    real z = gauss(0.75,9,x,2,4,9,y,2,4) \
           + gauss(0.75,9,x,-1,49,9,y,-1,10) \
           + gauss(0.5,9,x,7,4,9,y,3,4) \
           - gauss(0.2,9,x,4,1,9,y,7,1);
    return z;
}

triple exact(pair ij){
    int i = (int) round(ij.x);
    int j = (int) round(ij.y);
    return (x1[i], x2[j], y_exact[i*n+j]);
}

triple approx(pair x){
    real x1 = x.x;
    real x2 = x.y;
    real y = 0;
    int idx = 0;
    for(int j = 0; j <= d; j+=1){
        for(int i = 0; i <= d-j; i+=1){
            y += beta[idx] * x1**i * x2**j;
            idx += 1;
        }
    }
    return (x1, x2, y);
}

//write(m, n);
//write(x1);
//write(x2);
//write(y);

//s.colors(palette(s.map(new real(triple v) {return find(levels > v.z);}),Pal));

surface s = surface(exact, (0,0), (m-1,n-1),nu=m,nv=n);
draw(s,surfacepen=material(red+0.2*white+opacity(0.4)));

//pen[] pal = Grayscale();
pen[] pal = Rainbow();

surface s = surface(approx, (0,0), (1,1),nu=100,nv=100);
draw(s,surfacepen=material(red+0.2*white+opacity(0.6)));
s.colors(palette(s.map(new real(triple xyz) {return abs(xyz.z - franke(xyz.x,xyz.y));}), pal));

axes3("$x_1$","$x_2$","$y$",min=(-0.2,-0.2,-0.2),max=(1.2,1.2,1.2),arrow=Arrow3());
