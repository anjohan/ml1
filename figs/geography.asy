//string method = "OLS";

settings.outformat = "pdf";
settings.prc = false;
settings.render = 16;
size(15cm,10cm,IgnoreAspect);
import three;
import graph3;
import palette;
usepackage("mathpazo");

triple view = (1,3,4);
currentprojection=orthographic(view,up=Z);
currentlight=light(view);
real myopacity=0.6;

file in = input("data/geography.txt").line();
int m = in;
int n = in;
real[][] y = in;

triple exact(pair ij){
    int i = (int) round(ij.x);
    int j = (int) round(ij.y);
    return (j/(n-1.0), i/(m-1.0), y[j][i]);
}

surface s = surface(exact, (0,0), (m-1,n-1),nu=m,nv=n, Spline);
draw(s,mean(palette(s.map(zpart),Grayscale())) + 0.2*black);

axes3("$x_1$","$x_2$","$y$",min=(-0.2,-0.2,-0.2),max=(1.2,1.2,1.2),arrow=Arrow3());
