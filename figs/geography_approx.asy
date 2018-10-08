//string method = "OLS";

settings.outformat = "pdf";
settings.prc = false;
settings.render = 8;
size(10cm,6cm,IgnoreAspect);
import three;
import graph3;
import palette;
usepackage("mathpazo");

triple view = (1,3,4);
currentprojection=orthographic(view,up=Z);
currentlight=light(view);
real myopacity=0.6;

real[] beta = input("data/geography_beta").line().csv();

int p = beta.length;
int d = (int) round((-3+sqrt(9+8*(p-1)))/2);

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
    return (x2, x1, y);
}

surface s = surface(approx, (0,0), (1,1),nu=100,nv=100);
draw(s,mean(palette(s.map(zpart),Grayscale())) + 0.2*black);

axes3("$x_1$","$x_2$","$y$",min=(-0.2,-0.2,-0.2),max=(1.2,1.2,1.2),arrow=Arrow3());
