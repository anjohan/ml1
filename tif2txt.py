from math import sqrt
from imageio import imread
import sys

name = sys.argv[1][:-4]
image = imread(name + ".tif")
m, n = image.shape

if len(sys.argv) == 3:
    fraction = float(sys.argv[2])
else:
    fraction = 1

print(m, n, m * n)
m = int(round(m * sqrt(fraction)))
n = int(round(n * sqrt(fraction)))
print(m, n, m * n)

image = image[:m, :n]
image = image / float(image.max())

with open(name + ".txt", "w") as outfile:
    outfile.write("%d\n%d\n" % (m, n))
    for j in range(n):
        outfile.write(" ".join(map(str, image[:, j])) + "\n")
