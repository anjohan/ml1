settings.outformat = "pdf";
settings.prc = false;
settings.render = 16;
size(15cm,10cm,IgnoreAspect);
import three;
import graph3;
usepackage("mathpazo");

triple view = (1,4,1);
currentprojection=orthographic(view,up=Z);
currentlight=light(view);
real myopacity=1;//0.801

real gauss(real r, real px, real x, real x0, real sx, real py, real y, real y0, real sy){
    return r*exp(-(px*x-x0)*(px*x-x0)/sx - (py*y-y0)*(py*y-y0)/sy);
}

triple franke(pair xy){
    real x = xy.x;
    real y = xy.y;
    real z = gauss(0.75,9,x,2,4,9,y,2,4) \
           + gauss(0.75,9,x,-1,49,9,y,-1,10) \
           + gauss(0.5,9,x,7,4,9,y,3,4) \
           - gauss(0.2,9,x,4,1,9,y,7,1);
    return (x,y,z);
}

surface graf2 = surface(franke, (0,0), (1,1),nu=50,nv=50,Spline);
draw(graf2,surfacepen=material(blue+0.5*white+opacity(myopacity)));
axes3("$x_1$","$x_2$","$f(x_1,x_2)$",min=(-0.2,-0.2,-0.2),max=(1.2,1.2,1.2),arrow=Arrow3());
